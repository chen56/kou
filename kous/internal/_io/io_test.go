package _io_test

import (
	. "kous/check"
	"kous/internal/_io"
	"os"
	"path"
	"path/filepath"
	"testing"
)

//var logger = log.New(os.Stdout, "", 0)

func TestInstall(t *testing.T) {
	_io.CopyFile(AA(filepath.Abs("./uat_test.go")), path.Join(os.TempDir(), "TestInstall"))
}
