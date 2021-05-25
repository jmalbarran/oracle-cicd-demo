package com.example.application.persistence;

public class GreetingEntity {
	private String greeting;

	public GreetingEntity() {
		this.greeting=null;
	}

	public GreetingEntity(String greeting) {
		this.greeting=greeting;
	}

	public void setGreeting(String greeting) {
		this.greeting=greeting;
	}

	public String getGreeting() {
		return this.greeting;
	}

}
