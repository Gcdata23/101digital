package com.weather.forecast.api.config.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

import static org.springframework.http.HttpHeaders.AUTHORIZATION;

@Component
public class JwtFilter extends OncePerRequestFilter {

    String token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String authorizationHeader = request.getHeader(AUTHORIZATION);

        if(authorizationHeader!= null
                && authorizationHeader.startsWith("Bearer ")
                && authorizationHeader.substring(7).equals(token)){
            SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(token, null, null));
        } else {
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request,response);
    }
}
