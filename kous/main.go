package main

import (
	"context"
	"fmt"
	"kous/check"
	"log"
	"os"
	"os/exec"

	"github.com/hashicorp/terraform-exec/tfexec"
)

var logger = log.New(os.Stdout, "", log.LstdFlags)

func main() {
	// 关键：要设置mirror
	check.A(os.Setenv("TF_CLI_CONFIG_FILE", "./tencent.tfrc"))
	execPath := check.AA(exec.LookPath("terraform"))

	workingDir := "./"
	tf, err := tfexec.NewTerraform(workingDir, execPath)
	tf.SetLogger(logger)
	tf.SetStdout(os.Stdout)
	tf.SetStderr(os.Stderr)
	if err != nil {
		log.Fatalf("error running NewTerraform: %s", err)
	}

	err = tf.Init(context.Background(), tfexec.Upgrade(true))
	if err != nil {
		log.Fatalf("error running Init: %s", err)
	}

	state, err := tf.Show(context.Background())
	if err != nil {
		log.Fatalf("error running Show: %s", err)
	}

	fmt.Println(state.FormatVersion) // "0.1"

	check.A(tf.Apply(context.Background()))
}
