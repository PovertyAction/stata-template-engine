vers 11.2

matamac
matainclude ClassWriter DoFileWriter Function

mata:

class `BaseClassWriter' extends `ClassWriter' {
	public:
		virtual `SS' filename()
		void init(), write()

	protected:
		virtual pointer(`DoFileWriterS') scalar out()

	private:
		`SS' filename
		`DoFileWriterS' out
		pointer(`FunctionS') rowvector methods
		void write_methods(), write_pragma()
}

void `BaseClassWriter'::init(`SS' class_file,
	pointer(`FunctionS') rowvector template_methods)
{
	`FunctionS' write, put

	filename = class_file

	write.init("void", "write", "\`SS' s")
	put.init("void", "put", "|\`SS' s")
	methods = &write, &put, template_methods
}

`SS' `BaseClassWriter'::filename()
	return(filename)

pointer(`DoFileWriterS') scalar `BaseClassWriter'::out()
	return(&out)

void `BaseClassWriter'::write_pragma(`FunctionS' method)
{
	`RS' i
	for (i = 1; i <= method.args()->length(); i++)
		out.put("pragma unused " + method.args()->get(i)->name())
}

void `BaseClassWriter'::write_methods()
{
	`RS' i
	for (i = 1; i <= length(methods); i++) {
		out.put(sprintf("%s %s::%s(%s) {", methods[i]->type(), class_name(),
			methods[i]->name(), methods[i]->args()->tostring()))
		write_pragma(*methods[i])
		out.put(`"_error("method not implemented")"')
		out.put("}")
		out.put()
	}
}

void `BaseClassWriter'::write()
{
	out.open(filename)
	write_top()
	write_declaration("", methods)
	write_methods()
	write_bottom()
	out.close()
}

end
