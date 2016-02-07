vers 11.2

matamac
matainclude ClassesWriter

mata:

void ste(`LclNameS' _directory, `LclNameS' _base_class_file,
	`LclNameS' _control_class_name, `LclNameS' _complete_class_file)
{
	`ClassesWriterS' writer
	writer.init(
		st_local(_directory),
		st_local(_base_class_file),
		st_local(_control_class_name),
		st_local(_complete_class_file)
	)
	writer.write()
}

end
