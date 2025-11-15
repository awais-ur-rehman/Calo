//
//  HomeView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.foodItems.isEmpty {
                    emptyStateView
                } else {
                    foodListView
                }
                
                VStack {
                    Spacer()
                    cameraButton
                }
            }
            .navigationTitle("Calo")
        }
    }
    
    private var foodListView: some View {
        List {
            ForEach(viewModel.foodItems) { item in
                NavigationLink(destination: FoodDetailView(foodItem: item)) {
                    FoodCardView(foodItem: item)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: viewModel.deleteFoodItem)
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No food items scanned yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap the camera button to start")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var cameraButton: some View {
        NavigationLink(destination: CameraView(onFoodScanned: { foodItem in
            viewModel.addFoodItem(foodItem)
        })) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 70, height: 70)
                
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 30)
    }
}

#Preview {
    HomeView()
}

