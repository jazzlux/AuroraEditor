//
//  SideBar.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebar: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    @State
    public var selection: Int = 0

    @ObservedObject
    private var model: NavigatorModeSelectModel = .shared

    @State
    private var dropProposal: SplitViewProposalDropPosition?

    private let toolbarPadding: Double = -8.0

    var body: some View {
        VStack {
            switch selection {
            case 0:
                ProjectNavigator()
            case 1:
                SourceControlNavigatorView()
            case 2:
                FindNavigator(state: workspace.searchState ?? .init(workspace))
            case 6:
                HierarchyNavigator()
            case 7:
                ExtensionNavigator(data: workspace.extensionNavigatorData!)
                    .environmentObject(workspace)
            default:
                needsImplementation
            }
        }
        .splitView(availablePositions: [.top, .bottom, .center],
                   proposalPosition: $dropProposal,
                   margin: 0.35,
                   isProportional: true,
                   onDrop: { position, _ in
            // get the data
            if let draggingItem = model.draggingItem {
                moveIcon(draggingItem, to: position)
            }
        })
        .ignoresSafeArea(edges: (prefs.preferences.general.sidebarStyle == .xcode) ? [.leading] : [])
        .padding([.top, .leading], (prefs.preferences.general.sidebarStyle == .xcode) ? 0 : -10)
        .safeAreaInset(edge: .leading) { // VSC style sidebar
            if prefs.preferences.general.sidebarStyle == .vscode {
                NavigatorSidebarToolbar(selection: $selection,
                                        style: $prefs.preferences.general.sidebarStyle,
                                        toolbarNumber: .constant(0))
                .id("navToolbar")
                .safeAreaInset(edge: .trailing) {
                    // this complex thing is so that theres a vertical divider that goes from top to bottom
                    HStack {
                        Divider()
                            .padding(.bottom, -8)
                    }
                    .frame(width: 1)
                    .offset(x: -2, y: -8)
                }
            } else {
                HStack {
                }.frame(width: 0)
            }
        }
        .safeAreaInset(edge: .top) { // Xcode style sidebar
            if prefs.preferences.general.sidebarStyle == .xcode {
                NavigatorSidebarToolbar(selection: $selection,
                                        style: $prefs.preferences.general.sidebarStyle,
                                        toolbarNumber: .constant(0))
                .id("navToolbar")
                .padding(.bottom, toolbarPadding)
            } else {
                Divider()
            }
        }
        .safeAreaInset(edge: .bottom) {
            switch selection {
            case 0:
                ProjectNavigatorToolbarBottom()
                    .padding(.top, toolbarPadding)
            case 1:
                SourceControlToolbarBottom()
                    .padding(.top, toolbarPadding)
            case 2, 3, 4, 5, 6, 7:
                NavigatorSidebarToolbarBottom()
                    .padding(.top, toolbarPadding)
            default:
                NavigatorSidebarToolbarBottom()
                    .padding(.top, toolbarPadding)
            }
        }
    }

    var needsImplementation: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Text("Needs Implementation")
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
    }

    func moveIcon(_ icon: SidebarDockIcon, to position: SplitViewProposalDropPosition) {
        // if the icon is the current view, don't do anything
        guard selection != icon.id else { return }

        // if the icon was dragged to the center, focus it
        if position == .center {
            selection = icon.id
            return
        }

        // other things
        switch position {
        case .top:
            Log.info("Dropped \(icon.title) at the top")
        case .bottom:
            Log.info("Dropped \(icon.title) at the bottom")
        case .leading:
            Log.info("Dropped \(icon.title) at the start")
        case .trailing:
            Log.info("Dropped \(icon.title) at the end")
        case .center:
            Log.info("Dropped \(icon.title) at the center")
        }
    }
}
