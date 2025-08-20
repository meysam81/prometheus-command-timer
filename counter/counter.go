// Package counter, provides a means of incrementing a named counter.
package counter

import (
	"encoding/json"
	"fmt"
	_ "fmt"
	"io/ioutil"
	"os"
)

// IncrementNamedCounter takes a key, an increment value, and a JSON file path, and updates the value in the file
func IncrementNamedCounter(key string, increment int, filename string) (int, error) {
	jsonData, err := loadJSONFile(filename)
	if err != nil {
		return 0, err
	}

	existingValue, ok := jsonData[key]
	if !ok {
		jsonData[key] = increment
	} else {
		switch v := existingValue.(type) {
		case float64:
			jsonData[key] = v + float64(increment)
		case int64:
			jsonData[key] = v + int64(increment)
		case int32:
			jsonData[key] = v + int32(increment)
		case int:
			jsonData[key] = v + increment
		default:
			return 0, fmt.Errorf("value for key '%s' is not a valid numeric type", key)
		}
	}

	err = writeJSONFile(filename, jsonData)
	if err != nil {
		return 0, err
	}

	value, ok := jsonData[key]
	if !ok {
		return 1, nil
	}

	switch v := value.(type) {
	case float64:
		return int(v), nil
	case int64:
		return int(v), nil
	case int:
		return int(v), nil
	default:
		return 0, fmt.Errorf("value for key '%s' is not a valid int32", key)
	}
}

// writeJSONFile writes the map into a JSON file
func writeJSONFile(filename string, jsonData map[string]interface{}) error {
	updatedData, err := json.MarshalIndent(jsonData, "", "  ")
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(filename, updatedData, 0644)
	if err != nil {
		return err
	}

	return nil
}

// loadJSONFile reads the contents of a JSON file and returns a map[string]interface{}
func loadJSONFile(filename string) (map[string]interface{}, error) {

	if _, err := os.Stat(filename); os.IsNotExist(err) {
		err := ioutil.WriteFile(filename, []byte("{}"), 0644)
		if err != nil {
			return nil, fmt.Errorf("failed to create file: %w", err)
		}
	}

	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	var jsonData map[string]interface{}
	err = json.Unmarshal(data, &jsonData)
	if err != nil {
		return nil, err
	}

	return jsonData, nil
}
