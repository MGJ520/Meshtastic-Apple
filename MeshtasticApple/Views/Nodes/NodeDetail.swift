/*
Abstract:
A view showing the details for a node.
*/

import SwiftUI
import MapKit
import CoreLocation

struct NodeDetail: View {

	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var bleManager: BLEManager
	@EnvironmentObject var userSettings: UserSettings
	
	@State private var isPresentingShutdownConfirm: Bool = false
	@State private var isPresentingRebootConfirm: Bool = false

	var node: NodeInfoEntity

	var body: some View {
		
		let hwModelString = node.user?.hwModel ?? "UNSET"

		HStack {

			GeometryReader { bounds in

				VStack {

					if node.positions?.count ?? 0 >= 1 {

						let mostRecent = node.positions?.lastObject as! PositionEntity

						if mostRecent.coordinate != nil {

							let nodeCoordinatePosition = CLLocationCoordinate2D(latitude: mostRecent.latitude!, longitude: mostRecent.longitude!)

							let regionBinding = Binding<MKCoordinateRegion>(
								get: {
									MKCoordinateRegion(center: nodeCoordinatePosition, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
								},
								set: { _ in }
							)
							
							ZStack {
								
								let annotations = node.positions?.array as! [PositionEntity]
								
								Map(coordinateRegion: regionBinding,
									interactionModes: [.all],
									showsUserLocation: true,
									userTrackingMode: .constant(.follow),
									annotationItems: annotations
									
								)
								{ location in
									
									return MapAnnotation(
										coordinate: location.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
										
										   content: {
											   
											   NodeAnnotation(time: location.time!)
										   }
									)
								 }
								.frame(idealWidth: bounds.size.width, maxHeight: bounds.size.height / 2)
							    .ignoresSafeArea(.all, edges: [.leading, .trailing])
							}
							
						} else {

							Image(node.user?.hwModel ?? "UNSET")
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: bounds.size.width, height: bounds.size.height / 2)
						}
					} else {

						Image(node.user?.hwModel ?? "UNSET")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: bounds.size.width, height: bounds.size.height / 2)
					}

					ScrollView {
						
						HStack {
							if self.bleManager.connectedPeripheral != nil && self.bleManager.connectedPeripheral.num == node.num && self.bleManager.connectedPeripheral.num == node.num {
								
								if  hwModelString == "TBEAM" || hwModelString == "TECHO" || hwModelString.contains("4631") {
									
									Button(action: {
										
										isPresentingShutdownConfirm = true
									}) {
											
										Image(systemName: "power")
											.symbolRenderingMode(.hierarchical)
											.imageScale(.small)
											.foregroundColor(Color.accentColor)
										Text("Power Off")
											.font(.caption)
											
									}
									.padding()
									.background(Color(.systemGray6))
									.clipShape(Capsule())
									.confirmationDialog(
										"Are you sure?",
										isPresented: $isPresentingShutdownConfirm
									) {
										Button("Shutdown Node?", role: .destructive) {
											let success = bleManager.sendShutdown(destNum: node.num, wantResponse: false)
										}
									}
								}
							
								Button(action: {
									
									isPresentingRebootConfirm = true
									
								}) {
									
									Image(systemName: "arrow.triangle.2.circlepath")
										.symbolRenderingMode(.hierarchical)
										.imageScale(.small)
										.foregroundColor(Color.accentColor)
									Text("Reboot")
										.font(.caption)

								}
								.padding()
								.background(Color(.systemGray6))
								.clipShape(Capsule())
								.confirmationDialog(
									"Are you sure?",
									isPresented: $isPresentingRebootConfirm
									) {
									Button("Reboot Node?", role: .destructive) {
										let success = bleManager.sendReboot(destNum: node.num, wantResponse: false)
									}
								}
							}
						}
						.padding(5)
						Divider()
						HStack {

							Image(systemName: "clock.badge.checkmark.fill")
								.font(.title)
								.foregroundColor(.accentColor)
								.symbolRenderingMode(.hierarchical)
							
							LastHeardText(lastHeard: node.lastHeard).font(.title3)
						}
						.padding()
						Divider()

						HStack {

							VStack(alignment: .center) {
								Text("AKA").font(.title2).fixedSize()
								CircleText(text: node.user?.shortName ?? "???", color: .accentColor)
									.offset(y: 10)
							}
							.padding(5)

							Divider()

							VStack {

								if node.user != nil {
									
									Image(node.user!.hwModel ?? "UNSET")
										.resizable()
										.frame(width: 50, height: 50)
										.cornerRadius(5)

									Text(String(node.user!.hwModel ?? "UNSET"))
										.font(.callout).fixedSize()
								}
							}
							.padding(5)
							
							
							if node.snr > 0 {
								Divider()
								VStack(alignment: .center) {

									Image(systemName: "waveform.path")
										.font(.title)
										.foregroundColor(.accentColor)
										.symbolRenderingMode(.hierarchical)
									Text("SNR").font(.title2).fixedSize()
									Text(String(node.snr))
										.font(.title2)
										.foregroundColor(.gray)
										.fixedSize()
								}
								.padding(5)
							}

							if node.telemetries?.count ?? 0 >= 1 {

								let mostRecent = node.telemetries?.lastObject as! TelemetryEntity

								Divider()

								VStack(alignment: .center) {

									BatteryIcon(batteryLevel: mostRecent.batteryLevel, font: .title, color: .accentColor)
										.padding(.bottom)
									
									if mostRecent.batteryLevel > 0 {
										Text(String(mostRecent.batteryLevel) + "%")
											.font(.title3)
											.foregroundColor(.gray)
											.fixedSize()
									}
									
									Text(String(format: "%.2f", mostRecent.voltage) + " V")
										.font(.title3)
										.foregroundColor(.gray)
										.fixedSize()
								}
								.padding(5)
							}
						}
						.padding(4)

						Divider()

						HStack(alignment: .center) {
							VStack {
								HStack {
									Image(systemName: "person")
										.font(.title2)
										.foregroundColor(.accentColor)
										.symbolRenderingMode(.hierarchical)
									Text("User Id:").font(.title2)
								}
								Text(node.user?.userId ?? "??????").font(.title3).foregroundColor(.gray)
							}
							Divider()
							VStack {
								HStack {
								Image(systemName: "number")
										.font(.title2)
										.foregroundColor(.accentColor)
										.symbolRenderingMode(.hierarchical)
									Text("Node Number:").font(.title2)
								}
								Text(String(node.num)).font(.title3).foregroundColor(.gray)
							}
						}
						.padding(5)
						Divider()
						HStack {
							Image(systemName: "globe")
									.font(.headline)
									.foregroundColor(.accentColor)
									.symbolRenderingMode(.hierarchical)
							Text("MAC Address: ")
							Text(String(node.user?.macaddr?.macAddressString ?? "not a valid mac address")).foregroundColor(.gray)
						}
						.padding()

						if node.positions?.count ?? 0 >= 1 {

							Divider()

							HStack {

								Image(systemName: "location.circle.fill")
									.font(.title)
									.foregroundColor(.accentColor)
									.symbolRenderingMode(.hierarchical)
								Text("Location History").font(.title2)
							}
							.padding()

							Divider()
							
							ForEach(node.positions!.array as! [PositionEntity], id: \.self) { (mappin: PositionEntity) in
								
								if mappin.coordinate != nil {
									
									VStack {
										
										HStack {
										
											Image(systemName: "mappin.and.ellipse").foregroundColor(.accentColor) // .font(.subheadline)
											Text("Lat/Long:").font(.caption)
											Text("\(String(mappin.latitude ?? 0)) \(String(mappin.longitude ?? 0))")
												.foregroundColor(.gray)
												.font(.caption)

											Image(systemName: "arrow.up.arrow.down.circle")
												.font(.subheadline)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)

											Text("Alt:")
												.font(.caption)

											Text("\(String(mappin.altitude))m")
												.foregroundColor(.gray)
												.font(.caption)
										}
										
										HStack {
										
											Image(systemName: "clock.badge.checkmark.fill")
												.font(.subheadline)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
											Text("Time:")
												.font(.caption)
											DateTimeText(dateTime: mappin.time)
												.foregroundColor(.gray)
												.font(.caption)
											Divider()
										}
									}
								}
							}
						}
					}
				}
				.edgesIgnoringSafeArea([.leading, .trailing])
				.padding(1)
			}
		}
		.navigationTitle((node.user != nil)  ? String(node.user!.longName ?? "Unknown") : "Unknown")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarItems(trailing:

			ZStack {

				ConnectedDevice(
					bluetoothOn: bleManager.isSwitchedOn,
					deviceConnected: bleManager.connectedPeripheral != nil,
					name: (bleManager.connectedPeripheral != nil) ? bleManager.connectedPeripheral.lastFourCode : "????")
			}
		)
		.onAppear(perform: {

			self.bleManager.context = context
			self.bleManager.userSettings = userSettings

		})
	}
}

struct NodeInfoEntityDetail_Previews: PreviewProvider {

	static let bleManager = BLEManager()

	static var previews: some View {
		Group {

			// NodeDetail(node: node)
		}
	}
}