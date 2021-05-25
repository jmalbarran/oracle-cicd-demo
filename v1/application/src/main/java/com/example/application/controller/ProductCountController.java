package com.example.application.controller;

import java.math.BigDecimal;

import javax.sql.DataSource;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.web.bind.annotation.*;


import com.example.application.persistence.*;

@RestController
public class ProductCountController {
	private final DataSource dataSource;

	@Autowired
	public ProductCountController(DataSource dataSource) {
		this.dataSource=dataSource;
	}

	@GetMapping(value = "/productCount", produces = MediaType.APPLICATION_JSON_VALUE)
	public ProductCountEntity getProductCount() {
		SimpleJdbcCall call;
		SqlParameterSource params;

		BigDecimal count;

		call=new SimpleJdbcCall(dataSource).withFunctionName("ProductCount");
		params=new MapSqlParameterSource();
		count=call.executeFunction(BigDecimal.class, params);

		return new ProductCountEntity(count.longValue());

	}

}
