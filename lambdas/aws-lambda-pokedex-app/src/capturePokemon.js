const { v4 } = require('uuid')
const AWS = require('aws-sdk')

const capturePokemon = async(event) => {
    try{
        const dynamodb = new AWS.DynamoDB.DocumentClient();
    
        const { idPokemon, pokemonName } = JSON.parse(event.body)
        const captureDate = new Date()
        const id = v4()
    
        const pokemon = {
            id,
            idPokemon,
            pokemonName,
            captureDate: captureDate.toISOString()
        }
    
        await dynamodb.put({
            TableName: 'PokemonTable',
            Item: pokemon
        }).promise()
    
        return{
            status: 200,
            body: JSON.stringify(pokemon)
        }
    } catch (error){
        console.log(error)
    }
};

module.exports = {
    capturePokemon
};