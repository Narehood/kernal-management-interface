
using TeeJee.Logging;
using TeeJee.FileSystem;
using TeeJee.JsonHelper;
using TeeJee.ProcessHelper;
using TeeJee.System;
using TeeJee.Misc;

namespace TeeJee.GtkHelper{

	using Gtk;

	// messages ----------------------------------------

	public void show_err_log(Gtk.Window parent, bool disable_log = true){
		if ((err_log != null) && (err_log.length > 0)){
			gtk_messagebox(_("Error"), err_log, parent, true);
		}

		if (disable_log){
			err_log_disable();
		}
	}

	public void gtk_do_events (){

		/* Do pending events */

		while(Gtk.events_pending ())
			Gtk.main_iteration ();
	}

	public void gtk_messagebox(
		string title, string message, Gtk.Window? parent_win, bool is_error = false){

		/* Shows a simple message box */

		var type = Gtk.MessageType.INFO;
		if (is_error){
			type = Gtk.MessageType.ERROR;
		}
		else{
			type = Gtk.MessageType.INFO;
		}

		var dlg = new CustomMessageDialog(title,message,type,parent_win, Gtk.ButtonsType.OK);
		dlg.run();
		dlg.destroy();
	}

	// icon ----------------------------------------------

	public Gdk.Pixbuf? get_app_icon(int icon_size, string format = ".png"){
		var img_icon = get_shared_icon(BRANDING_SHORTNAME, BRANDING_SHORTNAME + format,icon_size,"pixmaps");
		if (img_icon != null){
			return img_icon.pixbuf;
		}
		else{
			return null;
		}
	}

	public Gtk.Image? get_shared_icon(
		string icon_name,
		string fallback_icon_file_name,
		int icon_size,
		string icon_directory = ICON_DIR + "/images"){

		Gdk.Pixbuf pix_icon = null;
		Gtk.Image img_icon = null;

		try {
			Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();

			pix_icon = icon_theme.load_icon_for_scale (
				icon_name, Gtk.IconSize.MENU, icon_size, Gtk.IconLookupFlags.FORCE_SIZE);
				
		} catch (Error e) {
			//log_error (e.message);
		}

		string fallback_icon_file_path = "/usr/share/%s/%s".printf(icon_directory, fallback_icon_file_name);

		if (pix_icon == null){
			try {
				pix_icon = new Gdk.Pixbuf.from_file_at_size (fallback_icon_file_path, icon_size, icon_size);
			} catch (Error e) {
				log_error (e.message);
			}
		}

		if (pix_icon == null){
			log_error (_("Missing Icon") + ": '%s', '%s'".printf(icon_name, fallback_icon_file_path));
		}
		else{
			img_icon = new Gtk.Image.from_pixbuf(pix_icon);
		}

		return img_icon;
	}

	public Gdk.Pixbuf? get_shared_icon_pixbuf(string icon_name,
		string fallback_file_name,
		int icon_size,
		string icon_directory = ICON_DIR + "/images"){

		var img = get_shared_icon(icon_name, fallback_file_name, icon_size, icon_directory);
		var pixbuf = (img == null) ? null : img.pixbuf;
		return pixbuf;
	}

}
