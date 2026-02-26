// components/home/SuccessStories.tsx
import { useState } from 'react';
import { ChevronLeft, ChevronRight, Star, TrendingDown, TrendingUp } from 'lucide-react';

const stories = [
  {
    hotel: 'Mille Collines Hotel',
    location: 'Nyarugenge',
    image: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
    before: 'RWF 50,000 monthly disposal cost',
    after: 'RWF 30,000 monthly revenue',
    metrics: {
      diversion: '85%',
      co2: '12.5 tons',
      revenue: '+RWF 80k'
    },
    quote: "EcoTrade transformed our waste from an expense into a profit center. The platform is incredibly easy to use.",
    manager: 'Jean Pierre, Operations Manager'
  },
  {
    hotel: 'Marriott Kigali',
    location: 'Gasabo',
    image: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
    before: 'RWF 75,000 monthly disposal cost',
    after: 'RWF 45,000 monthly revenue',
    metrics: {
      diversion: '92%',
      co2: '18.3 tons',
      revenue: '+RWF 120k'
    },
    quote: "The real-time tracking and instant payments have revolutionized how we handle our recycling program.",
    manager: 'Agathe Uwase, Sustainability Director'
  },
  {
    hotel: 'Serena Hotel',
    location: 'Kicukiro',
    image: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
    before: 'RWF 35,000 monthly disposal cost',
    after: 'RWF 25,000 monthly revenue',
    metrics: {
      diversion: '78%',
      co2: '8.7 tons',
      revenue: '+RWF 60k'
    },
    quote: "Our Green Score improved dramatically, and we now have verifiable data for our sustainability reports.",
    manager: 'Mucyo Kagame, General Manager'
  }
];

const SuccessStories = () => {
  const [currentIndex, setCurrentIndex] = useState(0);

  const next = () => {
    setCurrentIndex((prev) => (prev + 1) % stories.length);
  };

  const prev = () => {
    setCurrentIndex((prev) => (prev - 1 + stories.length) % stories.length);
  };

  const story = stories[currentIndex];

  return (
    <section className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Success <span className="text-cyan-600">Stories</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            See how Kigali's leading hotels are transforming their waste management
          </p>
        </div>

        <div className="relative">
          {/* Main Story Card */}
          <div className="bg-gradient-to-br from-gray-50 to-white rounded-3xl shadow-xl overflow-hidden">
            <div className="grid lg:grid-cols-2">
              {/* Image Side */}
              <div className="relative h-64 lg:h-auto">
                <img
                  src={story.image}
                  alt={story.hotel}
                  className="w-full h-full object-cover"
                />
                <div className="absolute top-4 left-4 bg-white/90 backdrop-blur-sm px-4 py-2 rounded-full">
                  <div className="flex items-center">
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    ))}
                    <span className="ml-2 text-sm font-medium">5.0</span>
                  </div>
                </div>
              </div>

              {/* Content Side */}
              <div className="p-8 lg:p-12">
                <div className="mb-4">
                  <span className="text-sm font-semibold text-cyan-600 uppercase tracking-wider">
                    Featured Success
                  </span>
                  <h3 className="text-2xl font-bold text-gray-900 mt-2">{story.hotel}</h3>
                  <p className="text-gray-600">{story.location}</p>
                </div>

                {/* Before/After Comparison */}
                <div className="grid grid-cols-2 gap-4 mb-8">
                  <div className="bg-red-50 rounded-xl p-4">
                    <div className="flex items-center text-red-600 mb-2">
                      <TrendingDown className="w-4 h-4 mr-1" />
                      <span className="text-sm font-semibold">Before</span>
                    </div>
                    <p className="text-sm text-gray-700">{story.before}</p>
                  </div>
                  <div className="bg-cyan-50 rounded-xl p-4">
                    <div className="flex items-center text-cyan-600 mb-2">
                      <TrendingUp className="w-4 h-4 mr-1" />
                      <span className="text-sm font-semibold">After</span>
                    </div>
                    <p className="text-sm text-gray-700">{story.after}</p>
                  </div>
                </div>

                {/* Metrics Grid */}
                <div className="grid grid-cols-3 gap-4 mb-8">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-cyan-600">{story.metrics.diversion}</div>
                    <div className="text-xs text-gray-600">Waste Diversion</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-cyan-600">{story.metrics.co2}</div>
                    <div className="text-xs text-gray-600">CO₂ Saved</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-cyan-600">{story.metrics.revenue}</div>
                    <div className="text-xs text-gray-600">Revenue Impact</div>
                  </div>
                </div>

                {/* Quote */}
                <blockquote className="border-l-4 border-cyan-600 pl-4 mb-6">
                  <p className="text-gray-700 italic">"{story.quote}"</p>
                  <footer className="text-sm text-gray-600 mt-2">— {story.manager}</footer>
                </blockquote>

                {/* Video Button */}
                <span className="inline-flex items-center text-gray-400 cursor-not-allowed" title="Coming soon">
                  <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center mr-3">
                    <div className="w-0 h-0 border-t-8 border-b-8 border-l-12 border-transparent border-l-gray-400 ml-1"></div>
                  </div>
                  Watch full story — Coming soon
                </span>
              </div>
            </div>
          </div>

          {/* Navigation Buttons */}
          <button
            onClick={prev}
            className="absolute left-0 top-1/2 transform -translate-y-1/2 -translate-x-4 lg:-translate-x-6 bg-white rounded-full p-3 shadow-lg hover:shadow-xl transition-shadow"
          >
            <ChevronLeft className="w-6 h-6 text-gray-600" />
          </button>
          <button
            onClick={next}
            className="absolute right-0 top-1/2 transform -translate-y-1/2 translate-x-4 lg:translate-x-6 bg-white rounded-full p-3 shadow-lg hover:shadow-xl transition-shadow"
          >
            <ChevronRight className="w-6 h-6 text-gray-600" />
          </button>
        </div>

        {/* Dots Indicator */}
        <div className="flex justify-center mt-8 space-x-2">
          {stories.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentIndex(index)}
              className={`w-2 h-2 rounded-full transition-all ${
                index === currentIndex ? 'w-8 bg-cyan-600' : 'bg-gray-300'
              }`}
            />
          ))}
        </div>
      </div>
    </section>
  );
};

export default SuccessStories;