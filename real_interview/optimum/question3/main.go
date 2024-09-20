package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

type BlockInfo struct {
	data         map[string]interface{}
	hash         string
	previousHash string
	timestamp    time.Time
	pow          int
}

type Transaction struct {
	sender    string
	receiver  string
	amount    float64
	timestamp time.Time
}

type TxResponse struct {
	txHash string
	code   int
}

//https://api.cosmos.network/txs
//https://api.cosmos.network/blocks/%7Bheight%7D

const (
	API_URK = "https://api.cosmos.network"
)

func getBlockInfo(height int) (*BlockInfo, error) {
	resp, err := http.Get(API_URK + "/blocks/" + fmt.Sprintf("%d", height))
	if err != nil {
		log.Fatalln(err)
		return nil, err
	}
	//We Read the response body on the line below.
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln(err)
		return nil, err
	}

	data := &BlockInfo{}
	err = json.Unmarshal(body, &data)
	if err != nil {
		return nil, err
	}

	return data, nil
}

func sendTransaction(tx Transaction) (*TxResponse, error) {

	//Encode the data

	postBody, err := json.Marshal(tx)

	responseBody := bytes.NewBuffer(postBody)

	//Leverage Go's HTTP Post function to make request
	resp, err := http.Post(API_URK+"/txs", "application/json", responseBody)
	//Handle Error
	if err != nil {
		log.Fatalf("An Error Occured %v", err)

		return &TxResponse{
			txHash: "",
			code:   0,
		}, err
	}
	defer resp.Body.Close()

	//Read the response body
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln(err)

		return &TxResponse{
			txHash: "",
			code:   0,
		}, err
	}

	data := &TxResponse{}
	err = json.Unmarshal(body, &data)

	if err != nil {

		log.Fatalln(err)
		return &TxResponse{
			txHash: "",
			code:   0,
		}, err
	}

	return data, nil

}

func main() {

	block, err := getBlockInfo(1000000)
	if err != nil {
		log.Fatalln(err)
	}

	fmt.Printf("Block info hash %s ", block.hash)
	fmt.Printf("Block info index %v ", block.data)

	newTx := Transaction{
		sender:   "assfsfsfsfsf",
		receiver: "dadadaddada",
		amount:   float64(10),
	}
	txRespons, err := sendTransaction(newTx)

	if err != nil {
		log.Fatalln(err)
	}

	fmt.Printf("Tx result %d ", txRespons.code)
	fmt.Printf("Tx hash %s ", txRespons.txHash)
}
