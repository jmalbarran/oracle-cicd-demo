package com.example.application.controller;

import javax.sql.DataSource;

import com.example.application.persistence.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.web.bind.annotation.*;


@RestController
public class GreetingController {
	private final DataSource dataSource;

	@Autowired
	public GreetingController(DataSource dataSource) {
		this.dataSource=dataSource;
	}

	@GetMapping(value = "/greeting", produces = MediaType.APPLICATION_JSON_VALUE)
	public GreetingEntity getGreeting() {
		SimpleJdbcCall call;
		SqlParameterSource params;

		String greeting;

		call=new SimpleJdbcCall(dataSource).withFunctionName("Greeting");
		params=new MapSqlParameterSource();
		greeting=call.executeFunction(String.class, params);

		return new GreetingEntity(greeting);

	}

}
