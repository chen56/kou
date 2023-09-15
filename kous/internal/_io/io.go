package _io

import (
	"io"
	. "kous/check"
	"os"
	"path/filepath"
)

// CopyFile
// /    to: CopyFile("a/b.txt","c/")  == CopyFile("a/b.txt","c/b.txt")
func CopyFile(from string, to string) {
	fromFile := Ok2(os.Open(from))
	defer fromFile.Close()

	toStat := Ok2(os.Stat(to))
	if toStat.IsDir() {
		_, file := filepath.Split(from)
		to = filepath.Join(to, file)
	}

	toFile := Ok2(os.Create(to))
	defer toFile.Close()

	Ok2(io.Copy(toFile, fromFile))
}
