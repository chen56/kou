package test_test

import (
	"fmt"
	"github.com/hashicorp/go-version"
	"github.com/hashicorp/hc-install/product"
	"github.com/hashicorp/hc-install/releases"
	"github.com/hashicorp/terraform-exec/tfexec"
	. "kous/check"
	"log"
	"os"
	"os/exec"
	"testing"
)
import "github.com/stretchr/testify/assert"
import (
	"context"
)

var logger = log.New(os.Stdout, "", 0)

func TestHello(t *testing.T) {
	var is = assert.New(t)
	is.Equal(1, 1)
	///var/folders/d2/h5tnv_sx08g6s7jy3kcww5dm0000gp/T/terraform_1.0.6_darwin_amd64.zip4183135400
	///var/folders/d2/h5tnv_sx08g6s7jy3kcww5dm0000gp/T/terraform_4128723855
	fmt.Println("pwd:", AA(os.Getwd()))
	cmd := exec.Command("terraform", "-h")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	A(cmd.Run())
}
func TestHelloSss(t *testing.T) {
	var is = assert.New(t)

	is.Equal("sdk_*", fmt.Sprintf("%s_*", "sdk"))
	dstDir, err := os.MkdirTemp("", fmt.Sprintf("%s_*", "sdk"))
	is.NoError(err)
	is.Contains(dstDir, "/var/folders", "类似：/var/folders/d2/h5tnv_sx08g6s7jy3kcww5dm0000gp/T/sdk_3428658150\n")
}
func TestTerraformExec(t *testing.T) {
	installer := &releases.ExactVersion{
		Product: product.Terraform,
		Version: version.Must(version.NewVersion("1.0.6")),
	}
	//slogger:=slog.NewLogLogger(slog.NewJSONHandler(os.Stdout, nil),slog.LevelDebug)
	installer.SetLogger(logger)
	execPath, err := installer.Install(context.Background())
	if err != nil {
		log.Fatalf("error installing Terraform: %s", err)
	}

	workingDir := "/path/to/working/dir"
	tf, err := tfexec.NewTerraform(workingDir, execPath)
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
}
func TestTerraformExec2(t *testing.T) {
	c := "/Users/chen/Downloads/terraform"
	cmd := exec.Command(c, "init")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	A(cmd.Run())
}
