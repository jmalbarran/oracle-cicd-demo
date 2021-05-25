package com.example.application.controller;

import java.math.BigDecimal;

import javax.sql.*;
import java.sql.*;
import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;


import com.example.application.persistence.*;

@RestController
public class EditionController {
	private final DataSource dataSource;

	@Autowired
	public EditionController(DataSource dataSource) {
		this.dataSource=dataSource;
	}

	@GetMapping(value = "/edition/last", produces = MediaType.APPLICATION_JSON_VALUE)
	public EditionEntity getLastEdition() throws SQLException {
		String edition;		
		SimpleJdbcCall call;
		SqlParameterSource params;

		// Old style
		JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
		CallableStatement callableStatement = jdbcTemplate.getDataSource().getConnection().prepareCall("{? = call LASTEDITION()}");
		callableStatement.registerOutParameter(1,Types.CHAR);
		callableStatement.executeUpdate();
		edition=callableStatement.getString(1);

		// call=new SimpleJdbcCall(dataSource).withFunctionName("LASTEDITION");
		// params=new MapSqlParameterSource(); // Empty

		// edition=call.executeFunction(String.class, params);

		return new EditionEntity(edition);
	}

	@GetMapping(value = "/edition/current", produces = MediaType.APPLICATION_JSON_VALUE)
	public EditionEntity getCurrentEdition() {
		JdbcTemplate jdbcTemplate;
		String edition;

		jdbcTemplate=new JdbcTemplate(dataSource);
		
		edition=jdbcTemplate.queryForObject(
			"SELECT SYS_CONTEXT('USERENV', 'CURRENT_EDITION_NAME') FROM DUAL",
			String.class);

		return new EditionEntity(edition);
	}

	@PostMapping(value = "/edition", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
	public EditionEntity setEdition(@Valid @RequestBody EditionEntity edition) {
		JdbcTemplate jdbcTemplate;

		jdbcTemplate=new JdbcTemplate(dataSource);
		jdbcTemplate.execute(String.format("ALTER SESSION SET EDITION = %s",edition.getEdition()));

		return getCurrentEdition();
	}

}
