package com.example.application.persistence;

public class ProductCountEntity {
	private long count;

	public ProductCountEntity() {
		this.count=0;
	}

	public ProductCountEntity(long count) {
		this.count=count;
	}

	public void setCount(long count) {
		this.count=count;
	}

	public long getCount() {
		return this.count;
	}

}
