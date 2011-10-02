package models;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.Transient;

import play.Logger;
import play.db.jpa.Model;
import play.libs.Codec;
import util.Tools;

@Entity
public class Grid extends Model {

	public String session;

	@Lob
	public String grid;

	public Date created;

	public Grid() {
		this.created = new Date();
	}

}
