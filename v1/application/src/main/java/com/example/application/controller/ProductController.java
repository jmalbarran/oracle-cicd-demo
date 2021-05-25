package com.example.application.controller;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;


import com.example.application.persistence.*;

@RestController
public class ProductController {
	private final ProductRepository repository;

	public ProductController(ProductRepository repository) {
		this.repository=repository;
	}

	@GetMapping(value = "/product", produces = MediaType.APPLICATION_JSON_VALUE)
	public Iterable<ProductEntity> getProducts() {
			return repository.findAll();
	}
	@GetMapping(value = "/product/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
	public ProductEntity getProduct(@PathVariable long id){
			return repository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, String.format("Invalid product id %s", id)));
	}
	@PostMapping(value = "/product", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
	public ProductEntity createProduct(@Valid @RequestBody ProductEntity product) {
			return repository.save(product);
	}

	@DeleteMapping(value = "/product/{id}")
	public Long deleteProduct(@PathVariable long id){
			return repository.deleteById(id);
	}
	
}
