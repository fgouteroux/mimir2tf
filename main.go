//https://github.com/sl1pm4t/k2tf/blob/master/main.go
// Adapted to convert mimir prometheus yaml rules to HashiCorp's Terraform configuration language.

package main

import (
	"fmt"
	"os"
	"strconv"
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
	reverse           bool
)

func init() {
	// init command line flags
	flag.BoolVarP(&debug, "debug", "d", false, "enable debug output")
	flag.StringVarP(&input, "filepath", "f", "-", `file or directory that contains the YAML configuration to convert. Use "-" to read from stdin`)
	flag.StringVarP(&output, "output", "o", "-", `file or directory where Terraform config will be written`)
	flag.BoolVarP(&overwriteExisting, "overwrite-existing", "x", false, "allow overwriting existing output file(s)")
	flag.BoolVarP(&tf12format, "tf12format", "F", false, `Use Terraform 0.12 formatter`)
	flag.BoolVarP(&printVersion, "version", "v", false, `Print mimir2tf version`)
	flag.BoolVarP(&reverse, "reverse", "r", false, `Reverse mode (hcl to yaml)`)

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

	w, closer := SetupOutput(output, overwriteExisting)
	defer closer()

	if reverse {
		objs := ReadHCLInput(input)
		content := "groups:\n"
		for _, obj := range objs {
			for key, value := range obj["resource"].(map[string]interface{}) {
				if key == "mimir_rule_group_alerting" {
					for _, alertgroups := range value.(map[string]interface{}) {
						for _, alertgroup := range alertgroups.([]interface{}) {
							content += fmt.Sprintf("- name: %s\n  rules:\n", alertgroup.(map[string]interface{})["name"].(string))
							rules := alertgroup.(map[string]interface{})["rule"].([]interface{})
							for _, rule := range rules {
								content += fmt.Sprintf("  - alert: %s\n", rule.(map[string]interface{})["alert"].(string))
								expr := rule.(map[string]interface{})["expr"].(string)
								if strings.Contains(expr, "\n") {
									content += fmt.Sprintf("    expr: |\n")
									for _, line := range strings.Split(expr, "\n") {
										content += fmt.Sprintf("      %s\n", line)
									}
								} else {
									content += fmt.Sprintf("    expr: %s\n", expr)
								}
								if _, ok := rule.(map[string]interface{})["for"]; ok {
									content += fmt.Sprintf("    for: %s\n", rule.(map[string]interface{})["for"].(string))
								}
								if _, ok := rule.(map[string]interface{})["labels"]; ok {
									labels := rule.(map[string]interface{})["labels"].(map[string]interface{})
									if len(labels) > 0 {
										content += fmt.Sprintf("    labels:\n")
										for lname, lvalue := range labels {
											content += fmt.Sprintf("      %s: %s\n", lname, lvalue)
										}
									}
								}
								if _, ok := rule.(map[string]interface{})["annotations"]; ok {
									annotations := rule.(map[string]interface{})["annotations"].(map[string]interface{})
									if len(annotations) > 0 {
										content += fmt.Sprintf("    annotations:\n")
										for aname, avalue := range annotations {
											content += fmt.Sprintf("      %s: %s\n", aname, strconv.Quote(avalue.(string)))
										}
									}
								}
							}
						}
					}
				}
				if key == "mimir_rule_group_recording" {
					for _, recordgroups := range value.(map[string]interface{}) {
						for _, recordgroup := range recordgroups.([]interface{}) {
							content += fmt.Sprintf("- name: %s\n  rules:\n", recordgroup.(map[string]interface{})["name"].(string))
							rules := recordgroup.(map[string]interface{})["rule"].([]interface{})
							for _, rule := range rules {
								content += fmt.Sprintf("  - record: %s\n", rule.(map[string]interface{})["record"].(string))
								expr := rule.(map[string]interface{})["expr"].(string)
								if strings.Contains(expr, "\n") {
									content += fmt.Sprintf("    expr: |\n")
									for _, line := range strings.Split(expr, "\n") {
										content += fmt.Sprintf("      %s\n", line)
									}
								} else {
									content += fmt.Sprintf("    expr: %s\n", expr)
								}
								if _, ok := rule.(map[string]interface{})["labels"]; ok {
									labels := rule.(map[string]interface{})["labels"].(map[string]interface{})
									if len(labels) > 0 {
										content += fmt.Sprintf("    labels:\n")
										for lname, lvalue := range labels {
											content += fmt.Sprintf("      %s: %s\n", lname, lvalue)
										}
									}
								}
							}
						}
					}
				}
			}
		}
		fmt.Fprint(w, content)
		fmt.Fprintln(w)
		os.Exit(0)
	}

	objs := ReadYAMLInput(input)

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
				if len(rule.Labels) > 0 {
					resource += fmt.Sprintf("labels = {\n")
					for lname, lvalue := range rule.Labels {
						resource += fmt.Sprintf("%s = \"%s\"\n", lname, lvalue)
					}
					resource += fmt.Sprintf("}\n")
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
