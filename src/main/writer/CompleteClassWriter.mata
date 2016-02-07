vers 11.2

matamac
matainclude ClassWriter DoFileWriter Function MethodWriter Template

mata:

class `CompleteClassWriter' extends `ClassWriter' {
	public:
		virtual `SS' filename()
		pointer(`FunctionS') rowvector write()
		void init()

	protected:
		virtual pointer(`DoFileWriterS') scalar out()

	private:
		`SS' filename
		`SR' method_files
		`DoFileWriterS' out
		`NameS' parent

		pointer(`FunctionS') scalar write_method()
		pointer(`FunctionS') rowvector write_methods()
		void append()
}

void `CompleteClassWriter'::init(`SS' class_file, `NameS' parent,
	`SR' method_files)
{
	this.filename = class_file
	this.parent = parent
	if (length(method_files) == 0)
		_error("no method files")
	this.method_files = method_files
}

`SS' `CompleteClassWriter'::filename()
	return(filename)

pointer(`DoFileWriterS') scalar `CompleteClassWriter'::out()
	return(&out)

pointer(`FunctionS') scalar `CompleteClassWriter'::write_method(`SS' filename)
{
	`MethodWriterS' writer
	`TemplateS' templat

	templat.init(filename)
	writer.init(this, templat, out)
	writer.write()
	out.put()

	return(templat.method())
}

pointer(`FunctionS') rowvector `CompleteClassWriter'::write_methods()
{
	`RS' i
	pointer(`FunctionS') rowvector methods

	methods = J(1, length(method_files), NULL)
	for (i = 1; i <= length(method_files); i++)
		methods[i] = write_method(method_files[i])

	return(methods)
}

void `CompleteClassWriter'::append(`SS' filename)
{
	`SM' line
	`FileHandleS' fh
	fh = fopen(filename, "r")
	while ((line = fget(fh)) != J(0, 0, ""))
		out.put(line)
	fclose(fh)
}

pointer(`FunctionS') rowvector `CompleteClassWriter'::write()
{
	`SS' bottom
	pointer(`FunctionS') rowvector methods

	out = `DoFileWriter'()
	out.open(bottom = st_tempfilename())
	methods = write_methods()
	write_bottom()
	out.close()

	out = `DoFileWriter'()
	out.open(filename)
	write_top(parent)
	write_declaration("`" + parent + "'", methods)
	append(bottom)
	out.close()

	return(methods)
}

end
