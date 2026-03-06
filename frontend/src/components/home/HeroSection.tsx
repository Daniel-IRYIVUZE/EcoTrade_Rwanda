// components/home/HeroSection.tsx
import { useState, useEffect } from 'react';
import { ArrowRight, Award } from 'lucide-react';
import { Link } from 'react-router-dom';

const TARGETS = { waste: 1247, co2: 892, revenue: 3.2 };

const HeroSection = () => {
  const [counts, setCounts] = useState({ waste: 0, co2: 0, revenue: 0 });

  useEffect(() => {
    let frame: number;
    let start: number | null = null;
    const duration = 2200;

    const step = (timestamp: number) => {
      if (!start) start = timestamp;
      const progress = Math.min((timestamp - start) / duration, 1);
      const ease = 1 - Math.pow(1 - progress, 3);
      setCounts({
        waste: Math.round(TARGETS.waste * ease),
        co2: Math.round(TARGETS.co2 * ease),
        revenue: Math.round(TARGETS.revenue * 10 * ease) / 10,
      });
      if (progress < 1) frame = requestAnimationFrame(step);
    };

    frame = requestAnimationFrame(step);
    return () => cancelAnimationFrame(frame);
  }, []);

  return (
    <section className="relative overflow-hidden" style={{ background: 'linear-gradient(135deg, #064e3b 0%, #065f46 30%, #0e7490 70%, #0369a1 100%)' }}>
      {/* Background image overlay */}
      <div className="absolute inset-0 overflow-hidden">
        <div
          className="absolute inset-0 bg-cover bg-center bg-no-repeat"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=1920&q=80)',
            filter: 'brightness(0.18)',
          }}
        />
      </div>

      {/* Animated blur blobs */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-16 left-8 w-72 h-72 rounded-full mix-blend-overlay filter blur-3xl animate-pulse opacity-20" style={{ background: 'radial-gradient(circle, #10b981, transparent)' }} />
        <div className="absolute bottom-16 right-8 w-96 h-96 rounded-full mix-blend-overlay filter blur-3xl animate-pulse opacity-20" style={{ background: 'radial-gradient(circle, #0284c7, transparent)', animationDelay: '1s' }} />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28">
        <div className="space-y-8 max-w-3xl">
          {/* Badge */}
          <div className="inline-flex items-center bg-white/15 backdrop-blur-sm rounded-full px-4 py-2 text-white border border-white/20">
            <Award className="w-5 h-5 mr-2 text-emerald-300" />
            <span className="text-sm font-medium">Kigali's First Circular Economy Marketplace</span>
          </div>

          {/* Headline */}
          <h1 className="text-4xl lg:text-6xl font-bold text-white leading-tight">
            Transform Waste into{' '}
            <span className="text-yellow-300">Revenue</span>
            <br />
            <span className="text-emerald-300 text-3xl lg:text-4xl font-semibold">Kigali's B2B Circular Economy</span>
          </h1>

          <p className="text-xl text-cyan-100 max-w-xl leading-relaxed">
            Connecting Hotels, Recyclers, and Drivers for a Sustainable Future.
            Turn commercial waste into verified income while reducing Kigali's landfill load.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-wrap gap-4">
            <Link
              to="/login"
              className="group bg-white text-emerald-800 px-7 py-4 rounded-xl font-semibold hover:shadow-2xl hover:bg-emerald-50 transform hover:-translate-y-1 transition-all duration-300 flex items-center"
            >
              Join as Hotel
              <ArrowRight className="ml-2 w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </Link>
            <Link
              to="/login"
              className="bg-cyan-600 hover:bg-cyan-500 text-white px-7 py-4 rounded-xl font-semibold transform hover:-translate-y-1 transition-all duration-300 border border-cyan-400"
            >
              Partner as Recycler
            </Link>
            <Link
              to="/login"
              className="bg-white/10 hover:bg-white/20 backdrop-blur-sm text-white px-7 py-4 rounded-xl font-semibold transform hover:-translate-y-1 transition-all duration-300 border border-white/30"
            >
              Become a Driver
            </Link>
          </div>

          {/* Live Counters */}
          <div className="grid grid-cols-3 gap-6 pt-6 border-t border-white/20">
            <div>
              <p className="text-3xl lg:text-4xl font-bold text-white tabular-nums">
                {counts.waste.toLocaleString()}
              </p>
              <p className="text-emerald-200 text-sm mt-1">Tons Diverted</p>
            </div>
            <div>
              <p className="text-3xl lg:text-4xl font-bold text-white tabular-nums">
                {counts.co2}
              </p>
              <p className="text-emerald-200 text-sm mt-1">CO₂ Saved (tons)</p>
            </div>
            <div>
              <p className="text-3xl lg:text-4xl font-bold text-white tabular-nums">
                RWF {counts.revenue}M
              </p>
              <p className="text-emerald-200 text-sm mt-1">Revenue Generated</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;
