// pages/AboutPage.tsx
import { useState } from 'react';
import Navbar from '../../components/common/Navbar/Navbar';
import Footer from '../../components/common/Footer/Footer';
import MissionSection from '../../components/about/MissionSection';
import ProblemSolutionSection from '../../components/about/ProblemSolutionSection';
import TechnologyStack from '../../components/about/TechnologyStack';
import TeamSection from '../../components/about/TeamSection';
import TimelineSection from '../../components/about/TimelineSection';
import ImpactMetrics from '../../components/about/ImpactMetrics';
import PartnersSection from '../../components/about/PartnersSection';
import AdvisoryBoard from '../../components/about/AdvisoryBoard';
import ValuesSection from '../../components/about/ValuesSection';
import Modal from '../../components/common/Modal/Modal';

interface AboutModalContent {
  title: string;
  description: string;
  details?: string[];
}

const AboutPage = () => {
  const [aboutModal, setAboutModal] = useState<AboutModalContent | null>(null);

  const handleOpenModal = (content: AboutModalContent) => {
    setAboutModal(content);
  };

  const handleCloseModal = () => {
    setAboutModal(null);
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main>
        {/* Hero Section with Video Background */}
        <section className="relative h-[60vh] min-h-[500px] bg-gradient-to-r from-cyan-900 to-teal-800 overflow-hidden">
          {/* Video Overlay */}
          <div className="absolute inset-0">
            <div className="absolute inset-0 bg-black/50 z-10"></div>
            {/* Placeholder for video - in production, replace with actual video */}
            <div 
              className="w-full h-full bg-cover bg-center"
              style={{
                backgroundImage: 'url(https://images.unsplash.com/photo-1527689368864-3a821dbccc34?w=1600)',
              }}
            ></div>
          </div>

          {/* Content */}
          <div className="relative z-20 h-full flex items-center justify-center text-center text-white px-4">
            <div className="max-w-4xl">
              <h1 className="text-5xl lg:text-7xl font-bold mb-6 animate-fade-in">
                Closing the Loop on
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-300 to-teal-300"> Commercial Waste</span>
              </h1>
              <p className="text-xl lg:text-2xl text-cyan-50 max-w-3xl mx-auto leading-relaxed">
                EcoTrade is revolutionizing waste management in Kigali by connecting hotels, 
                restaurants, and cafés with recyclers through innovative technology.
              </p>
            </div>
          </div>
        </section>

        <MissionSection onReadMore={handleOpenModal} />
        <ImpactMetrics onReadMore={handleOpenModal} />
        <ProblemSolutionSection onReadMore={handleOpenModal} />
        <ValuesSection onReadMore={handleOpenModal} />
        <TechnologyStack onReadMore={handleOpenModal} />
        <TimelineSection onReadMore={handleOpenModal} />
        <TeamSection onReadMore={handleOpenModal} />
        <AdvisoryBoard onReadMore={handleOpenModal} />
        <PartnersSection onReadMore={handleOpenModal} />
      </main>

      <Modal
        isOpen={Boolean(aboutModal)}
        onClose={handleCloseModal}
        title={aboutModal?.title}
      >
        {aboutModal && (
          <div className="space-y-4">
            <p className="text-gray-700">{aboutModal.description}</p>
            {aboutModal.details && (
              <ul className="space-y-2 text-gray-600 list-disc list-inside">
                {aboutModal.details.map((detail, index) => (
                  <li key={index}>{detail}</li>
                ))}
              </ul>
            )}
          </div>
        )}
      </Modal>

      <Footer />
    </div>
  );
};

export default AboutPage;