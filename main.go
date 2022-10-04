//https://github.com/sl1pm4t/k2tf/blob/master/main.go
// Adapted to convert mimir prometheus yaml rules to HashiCorp's Terraform configuration language.

package main

import (
	"fmt"
	"os"
	"strings"

	flag "github.com/spf13/pflag"

	"github.com/hashicorp/hcl/hcl/printer"
	"github.com/hashicorp/hcl2/hclwrite"

	"github.com/rs/zerolog/log"
)

// Build time variables
var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

// Command line flags
var (
	debug             bool
	input             string
	output            string
	noColor           bool
	overwriteExisting bool
	tf12format        bool
	printVersion      bool
)

func init() {
	// init command line flags
	flag.BoolVarP(&debug, "debug", "d", false, "enable debug output")
	flag.StringVarP(&input, "filepath", "f", "-", `file or directory that contains the YAML configuration to convert. Use "-" to read from stdin`)
	flag.StringVarP(&output, "output", "o", "-", `file or directory where Terraform config will be written`)
	flag.BoolVarP(&overwriteExisting, "overwrite-existing", "x", false, "allow overwriting existing output file(s)")
	flag.BoolVarP(&tf12format, "tf12format", "F", false, `Use Terraform 0.12 formatter`)
	flag.BoolVarP(&printVersion, "version", "v", false, `Print mimir2tf version`)

	flag.Parse()

	setupLogOutput()
}

func main() {
	if printVersion {
		fmt.Printf("mimir2tf version: %s\n", version)
		os.Exit(0)
	}

	log.Debug().
		Str("version", version).
		Str("commit", commit).
		Str("builddate", date).
		Msg("starting mimir2tf")

	objs := ReadInput(input)

	w, closer := SetupOutput(output, overwriteExisting)
	defer closer()

	var resources []string

	// generate mimir_rule_group_alerting terraform resources
	for _, obj := range objs {
		for _, group := range obj.Groups {
			var alertingRule bool
			var resource string
			resource = fmt.Sprintf("resource \"mimir_rule_group_alerting\" \"%s\" {\n", group.Name)
			resource += fmt.Sprintf("name      = \"%s\"\n", group.Name)
			if obj.Namespace != "" {
				resource += fmt.Sprintf("namespace = \"%s\"\n", obj.Namespace)
			}
			for _, rule := range group.Rules {
				var ruleName string
				if rule.Alert.Value != "" {
					ruleName = rule.Alert.Value
					alertingRule = true
				} else {
					continue
				}
				resource += fmt.Sprintf("rule {\n")
				resource += fmt.Sprintf("alert = \"%s\"\n", ruleName)
				ruleExpr := strings.TrimSuffix(rule.Expr.Value, "\n")
				if strings.Contains(ruleExpr, "\n") {
					resource += fmt.Sprintf("expr  = <<EOT\n%s\nEOT\n", ruleExpr)
				} else if strings.Contains(ruleExpr, "\"") {
					resource += fmt.Sprintf("expr  = \"%s\"\n", strings.ReplaceAll(ruleExpr, "\"", "\\\""))
				} else {
					resource += fmt.Sprintf("expr  = \"%s\"\n", ruleExpr)
				}
				if rule.For != 0 {
					resource += fmt.Sprintf("for  = \"%s\"\n", rule.For)
				}
				if len(rule.Labels) > 0 {
					resource += fmt.Sprintf("labels = {\n")
					for lname, lvalue := range rule.Labels {
						resource += fmt.Sprintf("%s = \"%s\"\n", lname, lvalue)
					}
					resource += fmt.Sprintf("}\n")
				}
				if len(rule.Annotations) > 0 {
					resource += fmt.Sprintf("annotations = {\n")
					for aname, avalue := range rule.Annotations {

						annotValue := strings.TrimSuffix(avalue, "\n")
						if strings.Contains(annotValue, "\n") {
							resource += fmt.Sprintf("%s = <<EOT\n%s\nEOT\n", aname, annotValue)
						} else if strings.Contains(annotValue, "\"") {
							resource += fmt.Sprintf("%s = \"%s\"\n", aname, strings.ReplaceAll(annotValue, "\"", "\\\""))
						} else {
							resource += fmt.Sprintf("%s = \"%s\"\n", aname, strings.ReplaceAll(annotValue, "\"", "\\\""))
						}
					}
					resource += fmt.Sprintf("}\n")
				}
				resource += fmt.Sprintf("}\n")
			}
			resource += fmt.Sprintf("}\n")
			if alertingRule {
				resources = append(resources, resource)
			}
		}
	}

	// generate mimir_rule_group_recording terraform resources
	for _, obj := range objs {
		for _, group := range obj.Groups {
			var recordingRule bool
			var resource string
			resource = fmt.Sprintf("resource \"mimir_rule_group_recording\" \"%s\" {\n", group.Name)
			resource += fmt.Sprintf("name = \"%s\"\n", group.Name)
			if obj.Namespace != "" {
				resource += fmt.Sprintf("namespace = \"%s\"\n", obj.Namespace)
			}
			for _, rule := range group.Rules {
				var ruleName string
				if rule.Record.Value != "" {
					ruleName = rule.Record.Value
					recordingRule = true
				} else {
					continue
				}
				resource += fmt.Sprintf("rule {\n")
				resource += fmt.Sprintf("record = \"%s\"\n", ruleName)
				ruleExpr := strings.TrimSuffix(rule.Expr.Value, "\n")
				if strings.Contains(ruleExpr, "\n") {
					resource += fmt.Sprintf("expr = <<EOT\n%s\nEOT\n", ruleExpr)
				} else if strings.Contains(ruleExpr, "\"") {
					resource += fmt.Sprintf("expr = \"%s\"\n", strings.ReplaceAll(ruleExpr, "\"", "\\\""))
				} else {
					resource += fmt.Sprintf("expr = \"%s\"\n", ruleExpr)
				}
				resource += fmt.Sprintf("}\n")
			}
			resource += fmt.Sprintf("}\n")
			if recordingRule {
				resources = append(resources, resource)
			}
		}
	}

	// output and format terraform resources
	for _, resource := range resources {
		formatted := formatObject([]byte(resource))
		fmt.Fprint(w, string(formatted))
		fmt.Fprintln(w)
	}

}

func formatObject(in []byte) []byte {
	var result []byte
	var err error

	if tf12format {
		result = hclwrite.Format(in)
	} else {
		result, err = printer.Format(in)
		if err != nil {
			log.Error().Err(err).Msg("could not format object")
			return in
		}
	}

	return result
}
