vers 11.2

matamac
matainclude ClassWriter DoFileWriter MethodBodyWriter Template

mata:

class `MethodWriter' {
	public:
		void init(), write()

	private:
		pointer(`ClassWriterS') scalar klass
		pointer(`DoFileWriterS') scalar out
		pointer(`TemplateS') scalar templat
}

void `MethodWriter'::init(`ClassWriterS' klass, `TemplateS' templat,
	`DoFileWriterS' out)
{
	this.klass = &klass
	this.templat = &templat
	this.out = &out
}

void `MethodWriter'::write()
{
	`MethodBodyWriterS' writer
	out->put(sprintf("%s %s::%s(%s)",
		templat->method()->type(),
		klass->class_name(),
		templat->method()->name(),
		templat->method()->args()->tostring()))
	out->put("{")
	writer.init(*templat, *out)
	writer.write()
	out->put("}")
}

end
