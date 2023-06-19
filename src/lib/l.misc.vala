// misc lib

namespace l.misc {

	private static void set_locale() {
		Intl.setlocale(LocaleCategory.MESSAGES,BRANDING_SHORTNAME);
		Intl.textdomain(BRANDING_SHORTNAME);
		Intl.bind_textdomain_codeset(BRANDING_SHORTNAME,"utf-8");
		Intl.bindtextdomain(BRANDING_SHORTNAME,LOCALE_DIR);
	}

	public void vprint(string s,int v=1,FileStream f=stdout,bool n=true) {
		if (v>Main.VERBOSE) return;
		string o = s;
		if (Main.VERBOSE>3) o = "%d: ".printf(Posix.getpid()) + o;
		if (n) o += "\n";
		f.printf(o);
		f.flush();
	}

	private static void pbar(int64 part=0,int64 whole=100,string units="") {
		if (Main.VERBOSE<1) return;
		int l = 80; // bar length
		if (whole<1) { vprint("\r%*.s\r".printf(l,""),1,stdout,false); return; }
		int64 c = 0, plen = 0, wlen = l/2;
		string b = "", u = units;
		if (whole>0) { c=(part*100/whole); plen=(part*wlen/whole); }
		else { c=100; plen=wlen; }
		for (int i=0;i<wlen;i++) { if (i<plen) b+="▓"; else b+="░"; }
		if (u.length>0) u = " "+part.to_string()+"/"+whole.to_string()+" "+u;
		vprint("\r%*.s\r%s %d%% %s ".printf(l,"",b,(int)c,u),1,stdout,false);
	}

	// rm -rf
	public bool rm(string path) {
		vprint("rm("+path+")",3);
		File p = File.new_for_path(path);
		if (!p.query_exists()) return true;
		if (p.query_file_type(FileQueryInfoFlags.NOFOLLOW_SYMLINKS) == FileType.DIRECTORY) try {
			FileEnumerator en = p.enumerate_children ("standard::*",FileQueryInfoFlags.NOFOLLOW_SYMLINKS,null);
			FileInfo i; File n; string s;
			while (((i = en.next_file(null)) != null)) {
				n = p.resolve_relative_path(i.get_name());
				s = n.get_path();
				if (i.get_file_type() == FileType.DIRECTORY) rm(s);
				else n.delete();
			}
		} catch (Error e) { print ("Error: %s\n", e.message); }
		try { p.delete(); } catch (Error e) { print ("Error: %s\n", e.message); }
		return !p.query_exists();
	}

	// mkdir -p
	public bool mkdir(string path) {
		vprint("mkdir("+path+")",3);
		return (DirUtils.create_with_parents(path,0775)==0);
	}

	public string? fread(string fname) {
		vprint("fread("+fname+")",3);
		string fdata = "";
		try { FileUtils.get_contents(fname, out fdata); }
		catch (Error e) { vprint(e.message,1,stderr); }
		return fdata;
	}

	public bool fwrite(string fname, string fdata) {
		vprint("fwrite("+fname+")",3);
		mkdir(Path.get_dirname(fname));
		try { FileUtils.set_contents(fname,fdata); return true;}
		catch (Error e) { vprint(e.message,1,stderr); return false; }
	}

	public bool exists(string path) {
		var t = FileTest.IS_REGULAR;
		if (path.has_suffix("/")) t = FileTest.IS_DIR;
		return (FileUtils.test(path, t));
	}

}
