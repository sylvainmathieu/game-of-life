package controllers;

import play.*;
import play.mvc.*;
import util.Tools;

import java.util.*;

import models.Grid;

public class GameOfLife extends Controller {

	public static void index() {
		session.put("sessionUnique", Tools.randomString(10));
		render();
	}

	public static void saveGrid(Grid grid) {
		grid.save();
		renderJSON(grid);
	}

	public static void getGrid(Long id) {
		Grid grid = Grid.findById(id);
		renderJSON(grid);
	}

}