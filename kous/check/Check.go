package check

func Check(err error) {
	if err != nil {
		panic(err)
	}
}
func Check1[T any](value T, err error) T {
	if err != nil {
		panic(err)
	}
	return value
}
