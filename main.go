package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

type FileStats struct {
	Filename string
	Total    int
	Inline   int
	Block    int
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Please provide a directory path")
		return
	}

	dir := os.Args[1]
	stats := processDirectory(dir)

	// Sort and print results
	sort.Slice(stats, func(i, j int) bool {
		return stats[i].Filename < stats[j].Filename
	})

	for _, stat := range stats {
		fmt.Printf("%s\ttotal: %d\tinline: %d\tblock: %d\n",
			stat.Filename, stat.Total, stat.Inline, stat.Block)
	}
}

func processDirectory(dir string) []FileStats {
	var stats []FileStats

	filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !info.IsDir() && (strings.HasSuffix(path, ".c") || strings.HasSuffix(path, ".cpp") ||
			strings.HasSuffix(path, ".h") || strings.HasSuffix(path, ".hpp")) {
			stat := processFile(path)
			stats = append(stats, stat)
		}

		return nil
	})

	return stats
}

func processFile(filename string) FileStats {
	content, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Printf("Error reading file %s: %v\n", filename, err)
		return FileStats{}
	}

	lines := strings.Split(string(content), "\n")
	total := len(lines)

	inlineCount, blockCount := countComments(string(content))

	return FileStats{
		Filename: strings.TrimPrefix(filename, "testing/cpp/"),
		Total:    total,
		Inline:   inlineCount,
		Block:    blockCount,
	}
}

func countComments(content string) (inlineCount, blockCount int) {
	const (
		CODE = iota
		STRING
		CHAR
		LINE_COMMENT
		BLOCK_COMMENT
		RAW_STRING
	)

	state := CODE
	rawStringDelimiter := ""
	blockCommentLines := 0

	// Regular expressions for various patterns
	reStringStart := regexp.MustCompile(`"`)
	reCharStart := regexp.MustCompile(`'`)
	reLineComment := regexp.MustCompile(`//`)
	reBlockCommentStart := regexp.MustCompile(`/\*`)
	reBlockCommentEnd := regexp.MustCompile(`\*/`)
	reRawStringStart := regexp.MustCompile(`R"([^(]*)\(`)
	reEscapeChar := regexp.MustCompile(`\\`)

	lines := strings.Split(content, "\n")

	for lineNum, line := range lines {
		i := 0
		for i < len(line) {
			switch state {
			case CODE:
				if loc := reStringStart.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = STRING
					i += loc[1]
				} else if loc := reCharStart.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = CHAR
					i += loc[1]
				} else if loc := reLineComment.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = LINE_COMMENT
					inlineCount++
					i += loc[1]
				} else if loc := reBlockCommentStart.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = BLOCK_COMMENT
					blockCommentLines = 1
					i += loc[1]
				} else if loc := reRawStringStart.FindStringSubmatchIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = RAW_STRING
					rawStringDelimiter = line[i+loc[2] : i+loc[3]]
					i += loc[1]
				} else {
					i++
				}
			case STRING:
				if loc := reStringStart.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = CODE
					i += loc[1]
				} else if loc := reEscapeChar.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					i += 2 // Skip escaped character
				} else {
					i++
				}
			case CHAR:
				if loc := reCharStart.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = CODE
					i += loc[1]
				} else if loc := reEscapeChar.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					i += 2 // Skip escaped character
				} else {
					i++
				}
			case LINE_COMMENT:
				i = len(line) // Move to end of line
			case BLOCK_COMMENT:
				if loc := reBlockCommentEnd.FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = CODE
					blockCount += blockCommentLines
					i += loc[1]
				} else {
					i = len(line) // Move to end of line
					if lineNum < len(lines)-1 {
						blockCommentLines++
					}
				}
			case RAW_STRING:
				endDelimiter := fmt.Sprintf(`)%s"`, rawStringDelimiter)
				if loc := regexp.MustCompile(regexp.QuoteMeta(endDelimiter)).FindStringIndex(line[i:]); loc != nil && loc[0] == 0 {
					state = CODE
					i += loc[1]
				} else {
					i++
				}
			}
		}

		// Handle case where block comment ends at the last line
		if state == BLOCK_COMMENT && lineNum == len(lines)-1 {
			blockCount += blockCommentLines
		}

		// Reset line comment state at end of each line
		if state == LINE_COMMENT {
			state = CODE
		}
	}

	return inlineCount, blockCount
}
