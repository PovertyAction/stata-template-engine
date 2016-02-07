vers 11.2

matamac
matainclude Arglist

mata:

class `Function' {
	public:
		`SS' type()
		`NameS' name()
		pointer(`ArglistS') scalar args()
		void init()

	private:
		`SS' type
		`NameS' name
		`ArglistS' args
}

void `Function'::init(`SS' type, `NameS' name, |`SS' args)
{
	this.type = type
	this.name = name
	this.args.init(args)
}

`SS' `Function'::type()
	return(type)

`NameS' `Function'::name()
	return(name)

pointer(`ArglistS') scalar `Function'::args()
	return(&args)

end
