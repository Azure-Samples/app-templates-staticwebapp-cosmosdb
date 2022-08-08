import { ApolloServer, gql } from "apollo-server-azure-functions";
import { ApolloServerPluginLandingPageGraphQLPlayground, ApolloServerPluginLandingPageDisabled } from 'apollo-server-core';
import typeDefs from './schema'
import resolvers from './resolvers'

const server = new ApolloServer({ 
    typeDefs, 
    resolvers,
    plugins: [
        process.env.NODE_ENV === 'production' ? ApolloServerPluginLandingPageDisabled() : ApolloServerPluginLandingPageGraphQLPlayground(),
      ], 
});

export default server.createHandler({
    cors: {
      origin: '*'
    },
});