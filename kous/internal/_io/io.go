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
	fromFile := AA(os.Open(from))
	defer fromFile.Close()

	if toStat := Stat(to); toStat != nil && toStat.IsDir() {
		_, file := filepath.Split(from)
		to = filepath.Join(to, file)
	}

	toFile := AA(os.Create(to))
	defer toFile.Close()

	AA(io.Copy(toFile, fromFile))
}

// Stat
// / if path not exists  return nil
func Stat(path string) os.FileInfo {
	toStat, err := os.Stat(path)
	if err != nil {
		Assert(os.IsNotExist(err), "_io.CopyFile() read file stat error:%s", err)
		return nil
	} else {
		return toStat
	}
}
