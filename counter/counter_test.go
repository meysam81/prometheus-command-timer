package counter

import (
	"path/filepath"
	"testing"
)

func TestThatANoneExistentCounterWillBeCreatedAndIncrements(t *testing.T) {
	tempDir := t.TempDir()
	testFile := filepath.Join(tempDir, "test.json")

	counter, err := IncrementNamedCounter("testCounter", 1, testFile)
	if err != nil {
		t.Errorf("Not expecting and err to be returned: %v", err)
	}
	if counter != 1 {
		t.Errorf("Counter expected to be 1 but got %d", counter)
	}

	counter, err = IncrementNamedCounter("testCounter", 1, testFile)
	if err != nil {
		t.Errorf("Not expecting and err to be returned: %v", err)
	}
	if counter != 2 {
		t.Errorf("Counter expected to be 2 but got %d", counter)
	}
}
