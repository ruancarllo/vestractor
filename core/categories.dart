library categories;

class University {
	String name;
	Uri origin;
	
	University(this.name, this.origin);

	List<Exam> exams = [];
}

class Exam {
	String year;
	Uri link;
	
	Exam(this.year, this.link);

	Uri? resolution = null;
	List<Question> questions = [];
}

class Question {
	String area;
	String id;
	String alternative;
	String image;
	
	Question(this.area, this.id, this.alternative, this.image);
}