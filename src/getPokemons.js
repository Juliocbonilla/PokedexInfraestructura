const AWS = require('aws-sdk')

const getPokemons = async (event) => {

    try {
        const dynamodb = new AWS.DynamoDB.DocumentClient();

     const result = await dynamodb.scan({
        TableName: 'PokemonTable'
    }).promise()

    const pokemons =  result.Items

    return {
        status: 200,
        body: {
            pokemons
        }
    }
    } catch (error) {
        console.log(error)
    }
}

module.exports = {
    getPokemons
}