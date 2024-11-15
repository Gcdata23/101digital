## spring-boot-weather-forecast-client-api

Purpose : Use openweathermap in spring boot API <br/>

### Local run steps <br/>
1- Start Spring Boot REST API by running main method containing class WeatherForecastClientAPI.java in your IDE. <br/>
<pre> 
spring-boot-weather-forecast-client-api $ mvn clean install -U -X <br/>
</pre>

swagger_ui can be accessed via http port 8082 from localhost : <br/>
http://localhost:8082/weather-forecast/swagger-ui/index.html#/ <br/><br/>


### Tech Stack
<pre>
Java 17
spring boot
spring boot starter data jpa
spring boot starter web
spring boot starter test
springdoc openapi ui
springfox swagger ui
logback
maven
mockito-core
mockito-junit-jupiter
mockito-inline
</pre>


## API OPERATIONS
### Authorization Header with Jwt token in every requests
### Operation 1 : Get Weather Forecast By City Id provided in http body
NOTE: In this scenario access token is in the application.properties file.

Method : HTTP.POST <br/>
URL : http://localhost:8082/weather-forecast/forecast/by-city-id <br/>
HTTP Request Body : <br/>
<pre>
{
    "cityId": 524901
}
</pre>

Curl Request : <br/>
<pre>
curl --location 'http://localhost:8082/weather-forecast/forecast/by-city-id' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9' \
--data '{
    "cityId": 524901
}'
</pre><br/>

Response :

HTTP response code 200 <br/>
<pre>
{
    "maxFeelsLike": 283.48,
    "maxHumidity": 96
}
</pre>

### Operation 2 : Get Weather Forecast By City Id and access token provided in query string
NOTE: In this scenario access token is provided in the query string directly.

Method : HTTP.GET <br/>
URL : http://localhost:8082/weather-forecast/forecast/get/524901/4d918421e250e65043de409947a79b28 <br/>
Request Body : <br/>
<pre>
{}
</pre>
Curl Request : <br/>
<pre>
curl --location 'http://localhost:8082/weather-forecast/forecast/get/524901/4d918421e250e65043de409947a79b28' \
--header 'Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9'
</pre>
<br/>

Response :

HTTP response code 200 <br/>
<pre>
{
    "maxFeelsLike": 283.48,
    "maxHumidity": 96
}
</pre>
<br/>

### Operation 3 : Get Weather Forecast By City Id provided in http request header

Method : HTTP.GET <br/>
URL : http://localhost:8082/weather-forecast/forecast/get/524901 <br/>
Request Body : <br/>
<pre>
{}
</pre>
Curl Request : <br/>
<pre>
curl --location 'http://localhost:8082/weather-forecast/forecast/get/524901' \
--header 'Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9'
</pre>
<br/>

Response :

HTTP response code 200 <br/>
<pre>
{
    "maxFeelsLike": 283.48,
    "maxHumidity": 96
}
</pre>
<br/>

