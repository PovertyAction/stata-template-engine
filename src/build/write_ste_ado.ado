pr write_ste_ado
	vers 11.2

	_find_project_root
	#d ;
	writeado
		using `"`r(path)'/src/build/ste.ado"',
		stata(main/stata.do)
		mata(
			DoFileWriter

			Arg
			Arglist
			Function

			Template

			ClassWriter
			BaseClassWriter
			MethodBodyWriter
			MethodWriter
			CompleteClassWriter
			ClassesWriter

			ste
		)
	;
	#d cr
end
