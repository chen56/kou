package kous_test

import (
	"fmt"
	. "kous/check"
	"os"
	"os/exec"
	"testing"
)
import "github.com/stretchr/testify/assert"

func TestHello(t *testing.T) {
	var is = assert.New(t)
	is.Equal(1, 1)

	fmt.Println("pwd:", Check1(os.Getwd()))
	cmd := exec.Command("terraform", "-h")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	Check(cmd.Run())
}
