package com.example.application.persistence;

import java.util.*;

import org.springframework.data.repository.CrudRepository;
import org.springframework.transaction.annotation.Transactional;

public interface ProductRepository extends CrudRepository<ProductEntity, Long> {
	@Transactional(readOnly = true)
	Optional<ProductEntity> findById(long Id);

	// JMA: JPA >=1.7
	@Transactional(readOnly = false)
	Long deleteById(long Id);
}
