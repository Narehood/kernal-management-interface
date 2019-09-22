/*
 * AppGtk.vala
 *
 * Copyright 2016 Tony George <teejee2008@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

using GLib;
using Gtk;
using Gee;
using Json;

using TeeJee.Logging;
using TeeJee.FileSystem;
using TeeJee.JsonHelper;
using TeeJee.ProcessHelper;
using TeeJee.GtkHelper;
using TeeJee.System;
using TeeJee.Misc;

public Main App;

[CCode(cname="BRANDING_SHORTNAME")] extern const string BRANDING_SHORTNAME;
[CCode(cname="BRANDING_LONGNAME")] extern const string BRANDING_LONGNAME;
[CCode(cname="BRANDING_VERSION")] extern const string BRANDING_VERSION;
[CCode(cname="BRANDING_AUTHORNAME")] extern const string BRANDING_AUTHORNAME;
[CCode(cname="BRANDING_AUTHOREMAIL")] extern const string BRANDING_AUTHOREMAIL;
[CCode(cname="BRANDING_WEBSITE")] extern const string BRANDING_WEBSITE;
public const string ICON_DIR = BRANDING_SHORTNAME;

const string LOCALE_DIR = "/usr/share/locale";

public class AppGtk : GLib.Object {

	public static int main (string[] args) {
		
		set_locale();

		log_msg("%s v%s".printf(BRANDING_SHORTNAME, BRANDING_VERSION));

		Gtk.init(ref args);

		init_tmp(BRANDING_SHORTNAME+"-gtk");
		
		//check_if_admin();

		LOG_TIMESTAMP = false;

		//check dependencies
		string message;
		if (!Main.check_dependencies(out message)) {
			gtk_messagebox("", message, null, true);
			exit(0);
		}

		App = new Main(args, true);
		parse_arguments(args);

		// create main window --------------------------------------

		var window = new MainWindow ();
		
		window.destroy.connect(()=>{
			log_debug("MainWindow destroyed");
			Gtk.main_quit();
		});
		
		window.delete_event.connect((event)=>{
			log_debug("MainWindow closed");
			Gtk.main_quit();
			return true;
		});

		if (App.command == "list"){
			window.show_all();
		}

		//start event loop -------------------------------------
		
		Gtk.main();

		App.save_app_config();

		return 0;
	}

	private static void set_locale() {
		Intl.setlocale(GLib.LocaleCategory.MESSAGES, BRANDING_SHORTNAME);
		Intl.textdomain(BRANDING_SHORTNAME);
		Intl.bind_textdomain_codeset(BRANDING_SHORTNAME, "utf-8");
		Intl.bindtextdomain(BRANDING_SHORTNAME, LOCALE_DIR);
	}

	public static bool parse_arguments(string[] args) {

		log_msg(_("Cache") + ": %s".printf(LinuxKernel.CACHE_DIR));
		log_msg(_("Temp") + ": %s".printf(TEMP_DIR));

		App.command = "list";
		
		//parse options
		for (int k = 1; k < args.length; k++) // Oth arg is app path
		{
			switch (args[k].down()) {
				
			case "--debug":
				LOG_DEBUG = true;
				break;

			case "--help":
			case "--h":
			case "-h":
				log_msg(help_message());
				exit(0);
				return true;
			}
		}

		for (int k = 1; k < args.length; k++) // Oth arg is app path
		{
			switch (args[k].down()) {

			// commands ------------------------------------

			case "--install":
				App.command = "install";
				App.requested_version = args[++k];
				break;

			case "--notify":
				App.command = "notify";
				break;
				
			// options without argument --------------------------
			
			case "--help":
			case "--h":
			case "-h":
			case "--debug":
				// already handled - do nothing
				break;

			// options with argument --------------------------

			case "--user":
				k += 1;
				// already handled - do nothing
				break;

			default:
				//unknown option - show help and exit
				log_error(_("Unknown option") + ": %s".printf(args[k]));
				log_msg(help_message());
				return false;
			}
		}

		return true;
	}

	public static string help_message() {
		
		string msg = "\n" + BRANDING_SHORTNAME + " v" + BRANDING_VERSION + " - " + BRANDING_LONGNAME + "\n";
		msg += "\n";
		msg += _("Syntax") + ": " + BRANDING_SHORTNAME + "-gtk [options]\n";
		msg += "\n";
		msg += _("Options") + ":\n";
		msg += "\n";
		msg += "  --debug      " + _("Print debug information") + "\n";
		msg += "  --h[elp]     " + _("Show all options") + "\n";
		msg += "\n";
		return msg;
	}
}

