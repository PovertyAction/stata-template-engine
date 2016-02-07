vers 11.2

matamac
matainclude BaseClassWriter CompleteClassWriter Function

mata:

class `ClassesWriter' {
	public:
		void init(), write()

	private:
		`SS' directory, base_dest, complete_dest
		`SS' tempdir, base_temp, complete_temp
		`NameS' control

		pointer(`FunctionS') rowvector write_complete()
		void define_tempfiles(), create_tempdir(), copy_tempfiles(), move()
		void write_base()
}

void `ClassesWriter'::init(`SS' directory, `SS' base_class_file,
	`NameS' control_class_name, `SS' complete_class_file)
{
	this.directory = directory
	this.base_dest = base_class_file
	this.control = control_class_name
	this.complete_dest = complete_class_file
}

void `ClassesWriter'::create_tempdir()
{
	`SS' parent

	pragma unset parent
	pathsplit(st_tempfilename(), parent, "")
	parent = pathjoin(parent, "stata_template_engine")
	if (!direxists(parent))
		mkdir(parent)

	do {
		tempdir = pathjoin(parent, st_tempname())
	} while (direxists(tempdir))
	mkdir(tempdir)
}

void `ClassesWriter'::define_tempfiles()
{
	create_tempdir()
	base_temp     = pathjoin(tempdir, pathbasename(base_dest))
	complete_temp = pathjoin(tempdir, pathbasename(complete_dest))
}

void `ClassesWriter'::move(`SS' from, `SS' to)
{
	stata(sprintf(`"qui copy `"%s"' `"%s"', replace"', from, to))
	unlink(from)
}

void `ClassesWriter'::copy_tempfiles()
{
	move(base_temp, base_dest)
	move(complete_temp, complete_dest)
	rmdir(tempdir)
}

pointer(`FunctionS') rowvector `ClassesWriter'::write_complete()
{
	`SR' method_files
	`CompleteClassWriterS' writer
	method_files = dir(directory, "files", "*", `True')'
	writer.init(complete_temp, control, method_files)
	return(writer.write())
}

void `ClassesWriter'::write_base(pointer(`FunctionS') rowvector methods)
{
	`BaseClassWriterS' base_writer
	base_writer.init(base_temp, methods)
	base_writer.write()
}

void `ClassesWriter'::write()
{
	pointer(`FunctionS') rowvector methods
	define_tempfiles()
	methods = write_complete()
	write_base(methods)
	copy_tempfiles()
}

end
