/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module app;

/** Import GtkD lib */
import gtk.Application, gtk.Builder;

/** Import MainWindow */
import kimp.window;

/**
 * The sart point of the app
 * Params:
 *   args = Input CLI arguments
 * Returns: 
 *   0 if everything is OK 
 */
int main(string [] args) {
	/** Create application instance */
	Application projectNApp = new Application("org.project.n.kimp", GApplicationFlags.FLAGS_NONE);
	
	/** Add the apps' activation */
	projectNApp.addOnActivate((app) {
		/** Load UI file */
		Builder bc = new Builder();
		bc.addFromFile("./resource/project_n.gtk4.ui");

		/** Create the main window */
		MainWindow projectNWin = new MainWindow(bc);

		/** Set the windows as used */
		projectNApp.addWindow(projectNWin);
	});

	/** Run the app and return the result */
	return projectNApp.run(args);
}
