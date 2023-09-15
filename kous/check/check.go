package check

import (
	"fmt"
	"reflect"
)

func Ok(err error) {
	if err != nil {
		panic(errorInfo(err))
	}
}
func Ok2[T any](value T, err error) T {
	if err != nil {
		panic(errorInfo(err))
	}
	return value
}
func errorInfo(err error) string {
	return fmt.Sprintf("check error[%s]:%s", reflect.TypeOf(err), err)
}
