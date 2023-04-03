// https://github.com/sl1pm4t/k2tf/blob/master/pkg/file_io/output.go
// changed file rights from 0755 to 0644

package main

import (
	"io"
	"os"

	"github.com/rs/zerolog/log"
)

var noOpCloser = func() {}

type CloseFunc func()

func SetupOutput(output string, overwriteExisting bool) (io.Writer, CloseFunc) {
	var closeFn CloseFunc
	var w io.Writer

	if output != "" && output != "-" {
		// writing to a file

		if _, err := os.Stat(output); err == nil && !overwriteExisting {
			// don't clobber
			log.Fatal().Str("file", output).Msg("output file already exists")
		}

		f, err := os.OpenFile(output, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0644)
		w = f
		if err != nil {
			log.Fatal().Err(err).Msg("")
		}
		log.Debug().Str("file", output).Msg("opened file")

		closeFn = func() {
			if err := f.Close(); err != nil {
				log.Fatal().Err(err).Msg("")
			}
			log.Debug().Str("file", output).Msg("closed output file")
		}

	} else {
		log.Debug().Msg("outputting to Stdout")
		w = os.Stdout
		closeFn = noOpCloser

	}

	return w, closeFn
}
