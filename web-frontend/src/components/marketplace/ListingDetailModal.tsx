// components/marketplace/ListingDetailModal.tsx
import { X, Heart, Share2, ChevronLeft, ChevronRight, Star, Mail } from 'lucide-react';
import { useState, useEffect } from 'react';

interface ListingDetailModalProps {
  listing: any;
  onClose: () => void;
  onBid: () => void;
}

const ListingDetailModal = ({ listing, onClose, onBid }: ListingDetailModalProps) => {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [saved, setSaved] = useState(false);

  // Close on Escape key
  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    document.addEventListener('keydown', handleKey);
    return () => document.removeEventListener('keydown', handleKey);
  }, [onClose]);

  const nextImage = () => {
    setCurrentImageIndex((prev) => (prev + 1) % listing.photos.length);
  };

  const prevImage = () => {
    setCurrentImageIndex((prev) => (prev - 1 + listing.photos.length) % listing.photos.length);
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex justify-between items-center z-10">
          <h2 className="text-xl font-bold text-gray-900">Listing Details</h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-4 sm:p-6">
          <div className="grid md:grid-cols-2 gap-6">
            {/* Left Column - Images */}
            <div>
              <div className="relative h-56 sm:h-80 rounded-xl overflow-hidden mb-4">
                <img
                  src={listing.photos[currentImageIndex]}
                  alt={listing.type}
                  className="w-full h-full object-cover"
                />
                
                {listing.photos.length > 1 && (
                  <>
                    <button
                      onClick={prevImage}
                      className="absolute left-2 top-1/2 transform -translate-y-1/2 bg-white/90 p-2 rounded-full shadow-lg hover:bg-white"
                    >
                      <ChevronLeft className="w-5 h-5" />
                    </button>
                    <button
                      onClick={nextImage}
                      className="absolute right-2 top-1/2 transform -translate-y-1/2 bg-white/90 p-2 rounded-full shadow-lg hover:bg-white"
                    >
                      <ChevronRight className="w-5 h-5" />
                    </button>
                  </>
                )}
              </div>

              {/* Thumbnails */}
              {listing.photos.length > 1 && (
                <div className="flex space-x-2 overflow-x-auto pb-2">
                  {listing.photos.map((photo: string, index: number) => (
                    <button
                      key={index}
                      onClick={() => setCurrentImageIndex(index)}
                      className={`flex-shrink-0 w-20 h-20 rounded-lg overflow-hidden border-2 ${
                        currentImageIndex === index ? 'border-cyan-600' : 'border-transparent'
                      }`}
                    >
                      <img src={photo} alt={`Thumbnail ${index + 1}`} className="w-full h-full object-cover" />
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Right Column - Details */}
            <div>
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-2xl font-bold text-gray-900">{listing.type}</h3>
                <div className="flex space-x-2">
                  <button
                    onClick={() => setSaved(!saved)}
                    className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                  >
                    <Heart className={`w-5 h-5 ${saved ? 'fill-red-500 text-red-500' : ''}`} />
                  </button>
                  <button className="p-2 hover:bg-gray-100 rounded-lg transition-colors">
                    <Share2 className="w-5 h-5" />
                  </button>
                </div>
              </div>

              {/* Hotel Info */}
              <div className="mb-6">
                <p className="text-lg font-semibold text-gray-800">{listing.hotel}</p>
                <div className="flex items-center mt-1">
                  <div className="flex">
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        className={`w-4 h-4 ${
                          i < Math.floor(listing.hotelRating)
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-gray-300'
                        }`}
                      />
                    ))}
                  </div>
                  <span className="text-sm text-gray-500 ml-2">{listing.hotelRating} • {listing.location}</span>
                </div>
              </div>

              {/* Key Details */}
              <div className="grid grid-cols-2 gap-4 mb-6">
                <div className="bg-gray-50 p-3 rounded-xl">
                  <p className="text-xs text-gray-500">Volume</p>
                  <p className="font-bold text-gray-900">{listing.volume} {listing.unit}</p>
                </div>
                <div className="bg-gray-50 p-3 rounded-xl">
                  <p className="text-xs text-gray-500">Quality</p>
                  <p className="font-bold text-gray-900">{listing.quality}</p>
                </div>
                <div className="bg-gray-50 p-3 rounded-xl">
                  <p className="text-xs text-gray-500">Distance</p>
                  <p className="font-bold text-gray-900">{listing.distance} km</p>
                </div>
                <div className="bg-gray-50 p-3 rounded-xl">
                  <p className="text-xs text-gray-500">Time Left</p>
                  <p className="font-bold text-red-600">{listing.timeLeft}</p>
                </div>
              </div>

              {/* Description */}
              <div className="mb-6">
                <h4 className="font-semibold text-gray-900 mb-2">Description</h4>
                <p className="text-gray-600">{listing.description}</p>
              </div>

              {/* Current Bids */}
              {listing.bids && listing.bids.length > 0 && (
                <div className="mb-6">
                  <h4 className="font-semibold text-gray-900 mb-3">Current Bids ({listing.bidCount})</h4>
                  <div className="space-y-3">
                    {listing.bids.map((bid: any, index: number) => (
                      <div key={index} className="flex items-center justify-between bg-gray-50 p-3 rounded-xl">
                        <div>
                          <p className="font-semibold text-gray-900">{bid.recycler}</p>
                          <p className="text-xs text-gray-500">{bid.time}</p>
                        </div>
                        <p className="font-bold text-cyan-600">RWF {bid.amount.toLocaleString()}</p>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex space-x-4">
                <button
                  onClick={onBid}
                  className="flex-1 bg-cyan-600 text-white py-3 rounded-xl font-semibold hover:bg-cyan-700 transition-colors"
                >
                  Place Bid
                </button>
                <a
                  href={`mailto:info@${listing.hotel.toLowerCase().replace(/\s+/g, '')}.com?subject=Waste%20Collection%20Inquiry&body=I%20am%20interested%20in%20your%20${encodeURIComponent(listing.type)}%20listing.`}
                  className="flex-1 border border-cyan-600 text-cyan-600 py-3 rounded-xl font-semibold hover:bg-cyan-50 transition-colors flex items-center justify-center gap-2"
                >
                  <Mail className="w-4 h-4" />
                  Contact Hotel
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ListingDetailModal;