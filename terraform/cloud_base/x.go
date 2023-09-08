package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path"

	"log/slog"

	"github.com/hashicorp/terraform-exec/tfexec"
)

var logger = slog.New(slog.NewTextHandler(os.Stderr, nil))
var loggerv1 = slog.NewLogLogger(logger.Handler(), slog.LevelDebug)

func main() {
	// installer := &releases.ExactVersion{
	// 	Product: product.Terraform,
	// 	Version: version.Must(version.NewVersion("1.0.6")),
	// }

	// execPath, err := installer.Install(context.Background())
	// if err != nil {
	// 	log.Fatalf("error installing Terraform: %s", err)
	// }

	currentDir, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}
	fmt.Println(currentDir) // for example /home/user
	workingDir := path.Join(currentDir, "xx")
	tf, err := tfexec.NewTerraform(workingDir, "terraform")
	if err != nil {
		log.Fatalf("error running NewTerraform: %s", err)
	}
	tf.SetLogger(&testingPrintfer{})

	err = tf.Init(context.Background(), tfexec.Upgrade(true))
	if err != nil {
		log.Fatalf("error running Init: %s", err)
	}

	state, err := tf.Show(context.Background())
	if err != nil {
		log.Fatalf("error running Show: %s", err)
	}

	fmt.Println(state.FormatVersion)    // "0.1"
	fmt.Println(state.TerraformVersion) // "0.1"
	fmt.Println(state.Values)           // "0.1"
}

type testingPrintfer struct {
}

func (t *testingPrintfer) Printf(format string, v ...interface{}) {
	logger.Info(format, v...)
}
