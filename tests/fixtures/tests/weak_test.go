package weak

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNoAssertion(t *testing.T) {
	_ = Slugify("Hello")
}

func TestWeakOnly(t *testing.T) {
	out, err := Parse("x")
	require.NoError(t, err)
	assert.NotNil(t, out)
}

func TestStrong(t *testing.T) {
	got := Slugify("Hello, World!")
	if got != "hello-world" {
		t.Errorf("got %q", got)
	}
}

func TestMockOnly(t *testing.T) {
	m := new(MockStore)
	m.AssertExpectations(t)
}
