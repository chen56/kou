package check

import (
	"fmt"
	"reflect"
)

func A(err error) {
	if err != nil {
		panic(errorInfo(err))
	}
}
func AA[R1 any](r1 R1, err error) R1 {
	if err != nil {
		panic(errorInfo(err))
	}
	return r1
}

func _[R1 any, R2 any](r1 R1, r2 R2, err error) (R1, R2) {
	if err != nil {
		panic(errorInfo(err))
	}
	return r1, r2
}
func Assert(expected bool, format string, a ...any) {
	if !expected {
		panic(fmt.Sprintf(format, a...))
	}
}
func errorInfo(err error) string {
	return fmt.Sprintf("check error[%s]:%s", reflect.TypeOf(err), err)
}
