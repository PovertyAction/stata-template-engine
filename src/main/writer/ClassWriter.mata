vers 11.2

matamac
matainclude DoFileWriter Function

mata:

class `ClassWriter' {
	public:
		virtual `SS' filename()
		`SS' class_name()

	protected:
		virtual pointer(`DoFileWriterS') scalar out()
		void write_top(), write_declaration(), write_bottom()
}

`SS' `ClassWriter'::filename()
	_error("method not implemented")

pointer(`DoFileWriterS') scalar `ClassWriter'::out()
	_error("method not implemented")

`SS' `ClassWriter'::class_name()
	return("`" + pathrmsuffix(pathbasename(filename())) + "'")

void `ClassWriter'::write_top(|`SR' matainclude)
{
	this.out()->put(sprintf("version %f", callersversion()))
	this.out()->put()
	this.out()->put("matamac")
	if (length(matainclude) > 0)
		this.out()->put("matainclude " + invtokens(matainclude))
	this.out()->put()
	this.out()->put("mata:")
	this.out()->put()
}

void `ClassWriter'::write_declaration(`SS' parent,
	pointer(`FunctionS') rowvector methods)
{
	`RS' i
	this.out()->write(sprintf("class %s ", class_name()))
	if (parent != "")
		this.out()->write(sprintf("extends %s ", parent))
	this.out()->put("{")
	this.out()->put("public:")
	this.out()->indent()
	for (i = 1; i <= length(methods); i++) {
		this.out()->put(sprintf("virtual %s %s()",
			methods[i]->type(), methods[i]->name()))
	}
	this.out()->indent(-1)
	this.out()->put("}")
	this.out()->put()
}

void `ClassWriter'::write_bottom()
	this.out()->put("end")

end
