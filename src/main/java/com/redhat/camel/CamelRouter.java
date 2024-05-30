package com.redhat.camel;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.rest.RestBindingMode;
import org.eclipse.microprofile.config.inject.ConfigProperty;

public class CamelRouter extends RouteBuilder{

    String standardMessage = "Hello World!";

    @ConfigProperty(name = "app.version")
    String applicationVersion;

    @Override
    public void configure() throws Exception {
       
        restConfiguration()
            .component("servlet")
            .bindingMode(RestBindingMode.off)
            .dataFormatProperty("prettyPrint", "true")
            .apiProperty("api.title", "Camel Quarkus Demo API")
            .apiProperty("api.version", applicationVersion)
            .apiProperty("cors", "true");

        rest("/dynamic")
            .tag("API de serviços Demo utilizando Camel e Quarkus")
            .produces("application/json")
            
            .get()
                .description("Retornar Hello World")
                .routeId("restClientGet")
                .to("direct:pega")
            .post()
                .description("Atualiza Hello World")
                .routeId("restClientPost")
                .to("direct:insere");
        
        from("direct:pega")
            .process(ex -> {
                ex.getIn().setBody(standardMessage);
            });

        from("direct:insere")
            .process(ex -> {
                standardMessage = ex.getIn().getBody(String.class);
            });


    }
    
}
