package main

type human interface {
	eat(string) string
}

type asia struct {
	name string
}

func (a *asia) eat(s string) string {
	return s + a.name
}

type euro struct {
	name string
}

func (e *euro) eat(s string) string {
	return s + e.name
}

func main() {
}
