package com.example.application.persistence;

public class EditionEntity {
	private String edition;

	public EditionEntity() {
		this.edition="NOT KNOWN";
	}

	public EditionEntity(String edition) {
		this.edition=edition;
	}

	public void setEdition(String edition) {
		this.edition=edition;
	}

	public String getEdition() {
		return this.edition;
	}

}
