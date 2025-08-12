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
	// Load the JSON data from the file
	jsonData, err := loadJSONFile(filename)
	if err != nil {
		return 0, err
	}

	// Get the existing value for the specified key
	existingValue, ok := jsonData[key]
	if !ok {
		jsonData[key] = increment
	} else {
		// Increment the value
		switch v := existingValue.(type) {
		case float64:
			println("float64")
			jsonData[key] = v + float64(increment)
		case int64:
			println("int64")
			jsonData[key] = v + int64(increment)
		case int32:
			println("int32")
			jsonData[key] = v + int32(increment)
		case int:
			println("int")
			jsonData[key] = v + increment
		default:
			return 0, fmt.Errorf("value for key '%s' is not a valid numeric type", key)
		}
	}

	err = writeJSONFile(filename, jsonData)
	if err != nil {
		return 0, err
	}

	// Get the value for the specified key and convert it to int32
	value, ok := jsonData[key]
	if !ok {
		return 1, nil // return 1 if key doesn't exist, default behaiviour
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

func writeJSONFile(filename string, jsonData map[string]interface{}) error {
	// Marshal the updated JSON data
	updatedData, err := json.MarshalIndent(jsonData, "", "  ")
	if err != nil {
		return err
	}

	// Write the updated data back to the file
	err = ioutil.WriteFile(filename, updatedData, 0644)
	if err != nil {
		return err
	}

	return nil
}

// loadJSONFile reads the contents of a JSON file and returns a map[string]interface{}
func loadJSONFile(filename string) (map[string]interface{}, error) {

	// Check if the file exists
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		// Create the file with an empty JSON object
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
